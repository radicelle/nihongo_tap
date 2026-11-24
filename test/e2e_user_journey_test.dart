import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nihongo_tap/main.dart';
import 'package:nihongo_tap/services/speech_service.dart';
import 'package:nihongo_tap/widgets/verb_conjugation_sheet.dart';

class RecordingSpeechService implements SpeechService {
  final List<({String text, bool slow})> calls = [];
  bool initialized = false;

  @override
  Future<bool> initialize() async {
    initialized = true;
    return true;
  }

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
  testWidgets('E2E learner journey: everyday tap, speed/romaji, search, categories, and verb conjugations', (
    tester,
  ) async {
    final speech = RecordingSpeechService();
    await tester.pumpWidget(NihongoTapApp(speechService: speech));
    await tester.pumpAndSettle();

    expect(speech.initialized, isTrue);

    // 1. Everyday flow & speed/romaji controls
    expect(find.text('ありがとう'), findsOneWidget);
    expect(find.text('すみません'), findsOneWidget);

    await tester.tap(find.text('ありがとう'));
    await tester.pump(const Duration(seconds: 1));
    expect(speech.calls.last, (text: 'ありがとう', slow: false));

    // Toggle slow speed (1× -> 0.7×)
    await tester.tap(find.text('1×'));
    await tester.pump();
    expect(find.text('0.7×'), findsOneWidget);

    await tester.tap(find.text('すみません'));
    await tester.pump(const Duration(seconds: 1));
    expect(speech.calls.last, (text: 'すみません', slow: true));

    // Toggle slow speed back to 1×
    await tester.tap(find.text('0.7×'));
    await tester.pump();
    expect(find.text('1×'), findsOneWidget);

    // Toggle Romaji off and back on
    expect(find.text('arigatou'), findsOneWidget);
    await tester.tap(find.text('Aa'));
    await tester.pump();
    expect(find.text('arigatou'), findsNothing);

    await tester.tap(find.text('Aa'));
    await tester.pump();
    expect(find.text('arigatou'), findsOneWidget);

    // 2. Search flow
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'water');
    await tester.pumpAndSettle();

    expect(find.text('水'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);
    await tester.tap(find.text('水'));
    await tester.pump(const Duration(seconds: 1));
    expect(speech.calls.last, (text: 'みず', slow: false));

    // Close search and verify list is restored
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('ありがとう'), findsOneWidget);

    // 3. Category navigation & Verb conjugation flow
    await tester.tap(find.text('Nouns'));
    await tester.pumpAndSettle();
    expect(find.text('水'), findsOneWidget);

    await tester.tap(find.text('Adjectives'));
    await tester.pumpAndSettle();
    expect(find.text('い'), findsWidgets);

    final otherTab = find.text('Other');
    await tester.ensureVisible(otherTab);
    await tester.tap(otherTab);
    await tester.pumpAndSettle();
    expect(find.text('ありがとう'), findsOneWidget);

    final verbsTab = find.text('Verbs');
    await tester.ensureVisible(verbsTab);
    await tester.tap(verbsTab);
    await tester.pumpAndSettle();

    // Open conjugation sheet for 食べる (first verb in Verbs list)
    expect(find.text('食べる'), findsOneWidget);
    await tester.tap(find.text('Forms').first);
    await tester.pumpAndSettle();

    expect(find.text('Ru-verb (Ichidan)'), findsOneWidget);
    await tester.ensureVisible(find.text('Te-form'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Te-form'));
    await tester.pump();
    expect(speech.calls.last, (text: 'たべて', slow: false));

    // Tap example sentence
    await tester.ensureVisible(find.text('朝ご飯を食べます。'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('朝ご飯を食べます。'));
    await tester.pump();
    expect(speech.calls.last, (text: 'あさごはんをたべます。', slow: false));

    // Dismiss bottom sheet
    Navigator.of(tester.element(find.byType(VerbConjugationSheet))).pop();
    await tester.pumpAndSettle();

    // Search for 行く on Verbs tab and verify Godan exception
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'go');
    await tester.pumpAndSettle();

    expect(find.text('行く'), findsOneWidget);
    await tester.tap(find.text('Forms').first);
    await tester.pumpAndSettle();

    expect(find.text('U-verb (Godan)'), findsOneWidget);
    await tester.ensureVisible(find.text('Te-form'));
    await tester.pumpAndSettle();
    expect(find.text('いって'), findsOneWidget);
    await tester.tap(find.text('Te-form'));
    await tester.pump();
    expect(speech.calls.last, (text: 'いって', slow: false));
  });
}
