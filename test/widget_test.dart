import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nihongo_tap/main.dart';
import 'package:nihongo_tap/services/speech_service.dart';
import 'package:nihongo_tap/services/update_service.dart';

class FakeUpdateService implements UpdateService {
  FakeUpdateService({this.updateInfo});

  final AppUpdateInfo? updateInfo;
  final List<String> openedUrls = [];

  @override
  Future<AppUpdateInfo?> checkForUpdate() async => updateInfo;

  @override
  Future<bool> openDownloadUrl(String url) async {
    openedUrls.add(url);
    return true;
  }
}

class FakeSpeechService implements SpeechService {
  FakeSpeechService({this.available = true});

  final bool available;
  final List<({String text, bool slow})> spoken = [];
  bool initialized = false;
  bool disposed = false;

  @override
  Future<bool> initialize() async {
    initialized = true;
    return available;
  }

  @override
  Future<void> speak(String text, {bool slow = false}) async {
    spoken.add((text: text, slow: slow));
  }

  @override
  Future<void> stop() async {}

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  testWidgets('displays Everyday list and speaks kana when a word is tapped', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    await tester.pumpWidget(NihongoTapApp(speechService: speech));
    await tester.pumpAndSettle();

    expect(speech.initialized, isTrue);
    expect(find.text('ありがとう'), findsOneWidget);
    expect(find.text('Thank you'), findsOneWidget);

    await tester.tap(find.text('ありがとう'));
    await tester.pump(const Duration(seconds: 1));

    expect(speech.spoken.length, 1);
    expect(speech.spoken.first.text, 'ありがとう');
    expect(speech.spoken.first.slow, isFalse);
  });

  testWidgets('Romaji toggle hides and shows romaji', (tester) async {
    final speech = FakeSpeechService();
    await tester.pumpWidget(NihongoTapApp(speechService: speech));
    await tester.pumpAndSettle();

    expect(find.text('arigatou'), findsOneWidget);

    await tester.tap(find.text('Aa'));
    await tester.pump();

    expect(find.text('arigatou'), findsNothing);

    await tester.tap(find.text('Aa'));
    await tester.pump();

    expect(find.text('arigatou'), findsOneWidget);
  });

  testWidgets('Slow toggle passes slow: true to SpeechService', (tester) async {
    final speech = FakeSpeechService();
    await tester.pumpWidget(NihongoTapApp(speechService: speech));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1×'));
    await tester.pump();
    expect(find.text('0.7×'), findsOneWidget);

    await tester.tap(find.text('すみません'));
    await tester.pump(const Duration(seconds: 1));

    expect(speech.spoken.last.text, 'すみません');
    expect(speech.spoken.last.slow, isTrue);
  });

  testWidgets('Verbs tab opens conjugation sheet and speaks conjugated form', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    await tester.pumpWidget(NihongoTapApp(speechService: speech));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verbs'));
    await tester.pumpAndSettle();

    expect(find.text('食べる'), findsOneWidget);
    expect(find.text('Forms'), findsWidgets);

    await tester.tap(find.text('Forms').first);
    await tester.pumpAndSettle();

    expect(find.text('Ru-verb (Ichidan)'), findsOneWidget);
    expect(find.text('Polite'), findsOneWidget);
    expect(find.text('たべます'), findsOneWidget);

    await tester.tap(find.text('Polite'));
    await tester.pump();

    expect(speech.spoken.last.text, 'たべます');
  });

  testWidgets('shows subtle banner when Japanese TTS is unavailable', (
    tester,
  ) async {
    final speech = FakeSpeechService(available: false);
    await tester.pumpWidget(NihongoTapApp(speechService: speech));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Japanese voice not detected'),
      findsOneWidget,
    );
  });

  testWidgets('shows update banner when newer release exists and handles tap/dismiss', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    const updateInfo = AppUpdateInfo(
      versionName: '1.0.5',
      versionCode: 5,
      downloadUrl:
          'https://github.com/radicelle/nihongo_tap/releases/download/v1.0.5/nihongo-tap-v1.0.5.apk',
    );
    final updater = FakeUpdateService(updateInfo: updateInfo);

    await tester.pumpWidget(
      NihongoTapApp(speechService: speech, updateService: updater),
    );
    await tester.pumpAndSettle();

    expect(find.text('Update available (v1.0.5)'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);

    await tester.tap(find.text('Download'));
    await tester.pump();
    expect(updater.openedUrls, [updateInfo.downloadUrl]);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.text('Update available (v1.0.5)'), findsNothing);
  });

  testWidgets('context dropdown defaults to All contexts and filters by context', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    await tester.pumpWidget(NihongoTapApp(speechService: speech));
    await tester.pumpAndSettle();

    expect(find.text('All contexts'), findsOneWidget);
    expect(find.text('ありがとう'), findsOneWidget);

    // Open context dropdown and select Wedding · 結婚式
    await tester.tap(find.byKey(const Key('context_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wedding · 結婚式').last);
    await tester.pumpAndSettle();

    expect(find.text('All contexts'), findsNothing);
    expect(find.text('Wedding · 結婚式'), findsOneWidget);
    expect(find.byType(Scrollable), findsNWidgets(2));

    // Wedding-tagged everyday word remains, non-wedding word is filtered out,
    // and non-everyday wedding words are visible in the filtered list.
    expect(find.text('ありがとう'), findsOneWidget);
    expect(find.text('水'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('結婚式'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('結婚式'), findsOneWidget);

    // Reset back to All contexts
    await tester.tap(find.byKey(const Key('context_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All contexts').last);
    await tester.pumpAndSettle();

    expect(find.text('ありがとう'), findsOneWidget);
    expect(find.text('結婚式'), findsNothing);
  });
}
