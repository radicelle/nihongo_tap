import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nihongo_tap/main.dart';
import 'package:nihongo_tap/services/speech_service.dart';

class _IntegrationSpeechService implements SpeechService {
  final List<({String text, bool slow})> calls = [];

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> speak(String text, {bool slow = false}) async {
    calls.add((text: text, slow: slow));
  }

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full app integration flow', (tester) async {
    final speech = _IntegrationSpeechService();
    await tester.pumpWidget(NihongoTapApp(speechService: speech));
    await tester.pumpAndSettle();

    // Verify Everyday list renders and speaks on tap
    expect(find.text('ありがとう'), findsOneWidget);
    await tester.tap(find.text('ありがとう'));
    await tester.pump(const Duration(seconds: 1));
    expect(speech.calls.last, (text: 'ありがとう', slow: false));

    // Toggle Romaji and Slow speed
    await tester.tap(find.text('Aa'));
    await tester.pump();
    expect(find.text('arigatou'), findsNothing);

    await tester.tap(find.text('1×'));
    await tester.pump();
    expect(find.text('0.7×'), findsOneWidget);

    // Search for a word
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'water');
    await tester.pumpAndSettle();
    expect(find.text('水'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Switch to Verbs and open Forms sheet
    await tester.tap(find.text('Verbs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forms').first);
    await tester.pumpAndSettle();

    expect(find.text('Ru-verb (Ichidan)'), findsOneWidget);
    await tester.ensureVisible(find.text('Polite'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Polite'));
    await tester.pump();
    expect(speech.calls.last, (text: 'たべます', slow: true));
  });
}
