import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_tap/data/vocabulary_data.dart';
import 'package:nihongo_tap/models/word_entry.dart';
import 'package:nihongo_tap/services/verb_conjugator.dart';

void main() {
  WordEntry findVerb(String id) =>
      kVocabularyList.firstWhere((w) => w.id == id);

  group('VerbConjugator - Ichidan', () {
    test('conjugates 食べる (taberu) accurately', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_taberu'));
      expect(forms.length, 6);

      expect(forms[0].fullKanji, '食べます');
      expect(forms[0].fullKana, 'たべます');
      expect(forms[0].stemKana, 'たべ');
      expect(forms[0].endingKana, 'ます');
      expect(forms[0].romaji, 'tabemasu');

      expect(forms[1].fullKana, 'たべません');
      expect(forms[2].fullKana, 'たべた');
      expect(forms[3].fullKana, 'たべて');
      expect(forms[4].fullKana, 'たべたい');
      expect(forms[5].fullKana, 'たべられる');
    });

    test('conjugates 見る (miru) accurately', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_miru'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'みます',
        'みません',
        'みた',
        'みて',
        'みたい',
        'みられる',
      ]);
      expect(forms.map((f) => f.fullKanji).toList(), [
        '見ます',
        '見ません',
        '見た',
        '見て',
        '見たい',
        '見られる',
      ]);
    });
  });

  group('VerbConjugator - Godan all endings + 行く exception', () {
    test('う ending: 買う (kau)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_kau'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'かいます',
        'かいません',
        'かった',
        'かって',
        'かいたい',
        'かえる',
      ]);
      expect(forms[3].romaji, 'katte');
    });

    test('つ ending: 待つ (matsu)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_matsu'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'まちます',
        'まちません',
        'まった',
        'まって',
        'まちたい',
        'まてる',
      ]);
    });

    test('る ending: 作る (tsukuru)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_tsukuru'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'つくります',
        'つくりません',
        'つくった',
        'つくって',
        'つくりたい',
        'つくれる',
      ]);
    });

    test('む ending: 飲む (nomu)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_nomu'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'のみます',
        'のみません',
        'のんだ',
        'のんで',
        'のみたい',
        'のめる',
      ]);
    });

    test('ぶ ending: 遊ぶ (asobu)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_asobu'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'あそびます',
        'あそびません',
        'あそんだ',
        'あそんで',
        'あそびたい',
        'あそべる',
      ]);
    });

    test('ぬ ending: 死ぬ (shinu)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_shinu'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'しにます',
        'しにません',
        'しんだ',
        'しんで',
        'しにたい',
        'しねる',
      ]);
    });

    test('く ending: 書く (kaku)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_kaku'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'かきます',
        'かきません',
        'かいた',
        'かいて',
        'かきたい',
        'かける',
      ]);
    });

    test('く exception: 行く (iku)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_iku'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'いきます',
        'いきません',
        'いった',
        'いって',
        'いきたい',
        'いける',
      ]);
      expect(forms[2].fullKanji, '行った');
      expect(forms[3].fullKanji, '行って');
      expect(forms[3].romaji, 'itte');
    });

    test('ぐ ending: 泳ぐ (oyogu)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_oyogu'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'およぎます',
        'およぎません',
        'およいだ',
        'およいで',
        'およぎたい',
        'およげる',
      ]);
    });

    test('す ending: 話す (hanasu)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_hanasu'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'はなします',
        'はなしません',
        'はなした',
        'はなして',
        'はなしたい',
        'はなせる',
      ]);
    });
  });

  group('VerbConjugator - Irregular verbs', () {
    test('する (suru)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_suru'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'します',
        'しません',
        'した',
        'して',
        'したい',
        'できる',
      ]);
    });

    test('compound 勉強する (benkyou suru)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_benkyousuru'));
      expect(forms.map((f) => f.fullKanji).toList(), [
        '勉強します',
        '勉強しません',
        '勉強した',
        '勉強して',
        '勉強したい',
        '勉強できる',
      ]);
      expect(forms[0].stemKanji, '勉強');
      expect(forms[0].endingKanji, 'します');
      expect(forms[0].fullKana, 'べんきょうします');
    });

    test('来る (kuru)', () {
      final forms = VerbConjugator.conjugate(findVerb('verb_kuru'));
      expect(forms.map((f) => f.fullKana).toList(), [
        'きます',
        'きません',
        'きた',
        'きて',
        'きたい',
        'こられる',
      ]);
      expect(forms.map((f) => f.fullKanji).toList(), [
        '来ます',
        '来ません',
        '来た',
        '来て',
        '来たい',
        '来られる',
      ]);
    });
  });

  test('non-verb entries produce empty conjugations and stems/endings reconstruct', () {
    final noun = kVocabularyList.firstWhere((w) => w.category == WordCategory.noun);
    expect(VerbConjugator.conjugate(noun), isEmpty);

    for (final verb in kVocabularyList.where((w) => w.category == WordCategory.verb)) {
      final forms = VerbConjugator.conjugate(verb);
      expect(forms.length, 6, reason: 'Verb ${verb.id} must have 6 forms');
      for (final form in forms) {
        expect(form.endingKana, isNotEmpty);
        expect(form.endingKanji, isNotEmpty);
        expect(form.fullKana, '${form.stemKana}${form.endingKana}');
        expect(form.fullKanji, '${form.stemKanji}${form.endingKanji}');
        expect(form.romaji, isNotEmpty);
      }
    }
  });
}
