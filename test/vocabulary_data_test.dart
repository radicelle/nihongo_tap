import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_tap/data/vocabulary_data.dart';
import 'package:nihongo_tap/models/word_entry.dart';
import 'package:nihongo_tap/services/verb_conjugator.dart';

void main() {
  test('all vocabulary entries have unique IDs and non-empty core fields', () {
    final ids = <String>{};
    for (final word in kVocabularyList) {
      expect(ids.add(word.id), isTrue, reason: 'Duplicate id: ${word.id}');
      expect(word.kana.trim(), isNotEmpty, reason: 'Empty kana on ${word.id}');
      expect(word.romaji.trim(), isNotEmpty, reason: 'Empty romaji on ${word.id}');
      expect(word.english.trim(), isNotEmpty, reason: 'Empty english on ${word.id}');
    }
  });

  test('Everyday tab contains at least 35 words sorted by everydayRank', () {
    final everyday = filterVocabulary(kVocabularyList, FilterTab.everyday, '');
    expect(everyday.length, greaterThanOrEqualTo(35));
    for (var i = 1; i < everyday.length; i++) {
      expect(
        everyday[i].everydayRank,
        greaterThanOrEqualTo(everyday[i - 1].everydayRank),
      );
    }
  });

  test('every category has substantial vocabulary entries', () {
    expect(
      filterVocabulary(kVocabularyList, FilterTab.nouns, '').length,
      greaterThanOrEqualTo(30),
    );
    expect(
      filterVocabulary(kVocabularyList, FilterTab.verbs, '').length,
      greaterThanOrEqualTo(25),
    );
    expect(
      filterVocabulary(kVocabularyList, FilterTab.adjectives, '').length,
      greaterThanOrEqualTo(20),
    );
    expect(
      filterVocabulary(kVocabularyList, FilterTab.other, '').length,
      greaterThanOrEqualTo(25),
    );
  });

  test('every verb has a verbGroup, examples, and valid conjugations', () {
    final verbs = filterVocabulary(kVocabularyList, FilterTab.verbs, '');
    for (final verb in verbs) {
      expect(verb.verbGroup, isNotNull, reason: 'Missing verbGroup: ${verb.id}');
      expect(verb.examples, isNotEmpty, reason: 'Missing examples: ${verb.id}');
      expect(VerbConjugator.conjugate(verb).length, 6);
    }
  });

  test('search filters across English, kana, kanji, and romaji', () {
    expect(
      filterVocabulary(kVocabularyList, FilterTab.nouns, 'water')
          .any((w) => w.id == 'noun_mizu'),
      isTrue,
    );
    expect(
      filterVocabulary(kVocabularyList, FilterTab.nouns, 'mizu')
          .any((w) => w.id == 'noun_mizu'),
      isTrue,
    );
    expect(
      filterVocabulary(kVocabularyList, FilterTab.nouns, '水')
          .any((w) => w.id == 'noun_mizu'),
      isTrue,
    );
  });
}
