import 'package:nihongo_tap/models/word_entry.dart';

/// Pure verb conjugation engine for Ichidan, Godan, and Irregular Japanese verbs.
class VerbConjugator {
  VerbConjugator._();

  static const Map<String, ({String iRow, String eRow, String te, String ta})>
      _godanRules = {
    'う': (iRow: 'い', eRow: 'え', te: 'って', ta: 'った'),
    'つ': (iRow: 'ち', eRow: 'て', te: 'って', ta: 'った'),
    'る': (iRow: 'り', eRow: 'れ', te: 'って', ta: 'った'),
    'む': (iRow: 'み', eRow: 'め', te: 'んで', ta: 'んだ'),
    'ぶ': (iRow: 'び', eRow: 'べ', te: 'んで', ta: 'んだ'),
    'ぬ': (iRow: 'に', eRow: 'ね', te: 'んで', ta: 'んだ'),
    'く': (iRow: 'き', eRow: 'け', te: 'いて', ta: 'いた'),
    'ぐ': (iRow: 'ぎ', eRow: 'げ', te: 'いで', ta: 'いだ'),
    'す': (iRow: 'し', eRow: 'せ', te: 'して', ta: 'した'),
  };

  /// Returns the 6 essential everyday conjugated forms for [verb],
  /// or an empty list if [verb.verbGroup] is null.
  static List<ConjugatedForm> conjugate(WordEntry verb) {
    final group = verb.verbGroup;
    if (group == null) return const [];

    return switch (group) {
      VerbGroup.ichidan => _conjugateIchidan(verb),
      VerbGroup.godan => _conjugateGodan(verb),
      VerbGroup.irregularSuru => _conjugateSuru(verb),
      VerbGroup.irregularKuru => _conjugateKuru(verb),
    };
  }

  static List<ConjugatedForm> _conjugateIchidan(WordEntry verb) {
    final stemKana = _stripSuffix(verb.kana, 'る');
    final stemKanji = verb.hasDistinctKanji
        ? _stripSuffix(verb.kanji, 'る')
        : stemKana;

    return [
      _buildForm(
        label: 'Polite',
        usageHint: 'Everyday polite present / future',
        stemKana: stemKana,
        endingKana: 'ます',
        stemKanji: stemKanji,
        endingKanji: 'ます',
      ),
      _buildForm(
        label: 'Polite Negative',
        usageHint: "Polite 'don't ...' / 'won't ...'",
        stemKana: stemKana,
        endingKana: 'ません',
        stemKanji: stemKanji,
        endingKanji: 'ません',
      ),
      _buildForm(
        label: 'Past (Casual)',
        usageHint: 'Casual past tense (did ...)',
        stemKana: stemKana,
        endingKana: 'た',
        stemKanji: stemKanji,
        endingKanji: 'た',
      ),
      _buildForm(
        label: 'Te-form',
        usageHint: "Connect actions or add ください for 'please'",
        stemKana: stemKana,
        endingKana: 'て',
        stemKanji: stemKanji,
        endingKanji: 'て',
      ),
      _buildForm(
        label: 'Want to',
        usageHint: "Expressing 'want to ...'",
        stemKana: stemKana,
        endingKana: 'たい',
        stemKanji: stemKanji,
        endingKanji: 'たい',
      ),
      _buildForm(
        label: 'Can do',
        usageHint: "Ability / 'can ...'",
        stemKana: stemKana,
        endingKana: 'られる',
        stemKanji: stemKanji,
        endingKanji: 'られる',
      ),
    ];
  }

  static List<ConjugatedForm> _conjugateGodan(WordEntry verb) {
    if (verb.kana.isEmpty) return const [];
    final lastChar = verb.kana.substring(verb.kana.length - 1);
    final rule = _godanRules[lastChar];
    if (rule == null) return const [];

    final stemKana = verb.kana.substring(0, verb.kana.length - 1);
    final stemKanji = verb.hasDistinctKanji && verb.kanji.isNotEmpty
        ? verb.kanji.substring(0, verb.kanji.length - 1)
        : stemKana;

    // 行く (いく) is the standard Godan te/ta exception: いって / いった.
    final isIku = verb.kana == 'いく' || verb.kana.endsWith('いく') && verb.kanji.endsWith('行く');
    final teEnding = isIku ? 'って' : rule.te;
    final taEnding = isIku ? 'った' : rule.ta;

    return [
      _buildForm(
        label: 'Polite',
        usageHint: 'Everyday polite present / future',
        stemKana: stemKana,
        endingKana: '${rule.iRow}ます',
        stemKanji: stemKanji,
        endingKanji: '${rule.iRow}ます',
      ),
      _buildForm(
        label: 'Polite Negative',
        usageHint: "Polite 'don't ...' / 'won't ...'",
        stemKana: stemKana,
        endingKana: '${rule.iRow}ません',
        stemKanji: stemKanji,
        endingKanji: '${rule.iRow}ません',
      ),
      _buildForm(
        label: 'Past (Casual)',
        usageHint: 'Casual past tense (did ...)',
        stemKana: stemKana,
        endingKana: taEnding,
        stemKanji: stemKanji,
        endingKanji: taEnding,
      ),
      _buildForm(
        label: 'Te-form',
        usageHint: "Connect actions or add ください for 'please'",
        stemKana: stemKana,
        endingKana: teEnding,
        stemKanji: stemKanji,
        endingKanji: teEnding,
      ),
      _buildForm(
        label: 'Want to',
        usageHint: "Expressing 'want to ...'",
        stemKana: stemKana,
        endingKana: '${rule.iRow}たい',
        stemKanji: stemKanji,
        endingKanji: '${rule.iRow}たい',
      ),
      _buildForm(
        label: 'Can do',
        usageHint: "Ability / 'can ...'",
        stemKana: stemKana,
        endingKana: '${rule.eRow}る',
        stemKanji: stemKanji,
        endingKanji: '${rule.eRow}る',
      ),
    ];
  }

  static List<ConjugatedForm> _conjugateSuru(WordEntry verb) {
    final prefixKana = _stripSuffix(verb.kana, 'する');
    final prefixKanji = verb.hasDistinctKanji
        ? _stripSuffix(verb.kanji, 'する')
        : prefixKana;

    return [
      _buildForm(
        label: 'Polite',
        usageHint: 'Everyday polite present / future',
        stemKana: prefixKana,
        endingKana: 'します',
        stemKanji: prefixKanji,
        endingKanji: 'します',
      ),
      _buildForm(
        label: 'Polite Negative',
        usageHint: "Polite 'don't ...' / 'won't ...'",
        stemKana: prefixKana,
        endingKana: 'しません',
        stemKanji: prefixKanji,
        endingKanji: 'しません',
      ),
      _buildForm(
        label: 'Past (Casual)',
        usageHint: 'Casual past tense (did ...)',
        stemKana: prefixKana,
        endingKana: 'した',
        stemKanji: prefixKanji,
        endingKanji: 'した',
      ),
      _buildForm(
        label: 'Te-form',
        usageHint: "Connect actions or add ください for 'please'",
        stemKana: prefixKana,
        endingKana: 'して',
        stemKanji: prefixKanji,
        endingKanji: 'して',
      ),
      _buildForm(
        label: 'Want to',
        usageHint: "Expressing 'want to ...'",
        stemKana: prefixKana,
        endingKana: 'したい',
        stemKanji: prefixKanji,
        endingKanji: 'したい',
      ),
      _buildForm(
        label: 'Can do',
        usageHint: "Ability / 'can ...'",
        stemKana: prefixKana,
        endingKana: 'できる',
        stemKanji: prefixKanji,
        endingKanji: 'できる',
      ),
    ];
  }

  static List<ConjugatedForm> _conjugateKuru(WordEntry verb) {
    final prefixKana = _stripSuffix(verb.kana, 'くる');
    final hasKanjiKuru = verb.hasDistinctKanji && verb.kanji.endsWith('来る');
    final prefixKanji = hasKanjiKuru
        ? '${_stripSuffix(verb.kanji, '来る')}来'
        : prefixKana;

    return [
      _buildForm(
        label: 'Polite',
        usageHint: 'Everyday polite present / future',
        stemKana: prefixKana,
        endingKana: 'きます',
        stemKanji: prefixKanji,
        endingKanji: hasKanjiKuru ? 'ます' : 'きます',
      ),
      _buildForm(
        label: 'Polite Negative',
        usageHint: "Polite 'don't ...' / 'won't ...'",
        stemKana: prefixKana,
        endingKana: 'きません',
        stemKanji: prefixKanji,
        endingKanji: hasKanjiKuru ? 'ません' : 'きません',
      ),
      _buildForm(
        label: 'Past (Casual)',
        usageHint: 'Casual past tense (came)',
        stemKana: prefixKana,
        endingKana: 'きた',
        stemKanji: prefixKanji,
        endingKanji: hasKanjiKuru ? 'た' : 'きた',
      ),
      _buildForm(
        label: 'Te-form',
        usageHint: "Connect actions or add ください for 'please'",
        stemKana: prefixKana,
        endingKana: 'きて',
        stemKanji: prefixKanji,
        endingKanji: hasKanjiKuru ? 'て' : 'きて',
      ),
      _buildForm(
        label: 'Want to',
        usageHint: "Expressing 'want to ...'",
        stemKana: prefixKana,
        endingKana: 'きたい',
        stemKanji: prefixKanji,
        endingKanji: hasKanjiKuru ? 'たい' : 'きたい',
      ),
      _buildForm(
        label: 'Can do',
        usageHint: "Ability / 'can come'",
        stemKana: prefixKana,
        endingKana: 'こられる',
        stemKanji: prefixKanji,
        endingKanji: hasKanjiKuru ? 'られる' : 'こられる',
      ),
    ];
  }

  static ConjugatedForm _buildForm({
    required String label,
    required String usageHint,
    required String stemKana,
    required String endingKana,
    required String stemKanji,
    required String endingKanji,
  }) {
    final fullKana = '$stemKana$endingKana';
    return ConjugatedForm(
      label: label,
      usageHint: usageHint,
      stemKana: stemKana,
      endingKana: endingKana,
      stemKanji: stemKanji,
      endingKanji: endingKanji,
      romaji: kanaToRomaji(fullKana),
    );
  }

  static String _stripSuffix(String value, String suffix) {
    if (value.endsWith(suffix)) {
      return value.substring(0, value.length - suffix.length);
    }
    return value;
  }

  /// Converts a Hiragana string (including っ, ん, and small ゃ/ゅ/ょ digraphs)
  /// into clean Hepburn-style Romaji.
  static String kanaToRomaji(String kana) {
    final buffer = StringBuffer();
    var i = 0;

    while (i < kana.length) {
      final current = kana[i];

      // Small tsu (っ): geminate the initial consonant of the following syllable.
      if (current == 'っ' && i + 1 < kana.length) {
        final nextRomaji = _matchKana(kana, i + 1).romaji;
        if (nextRomaji.isNotEmpty) {
          final firstConsonant = nextRomaji[0];
          if (firstConsonant == 'c' && nextRomaji.startsWith('ch')) {
            buffer.write('t');
          } else if (_isConsonant(firstConsonant)) {
            buffer.write(firstConsonant);
          }
        }
        i += 1;
        continue;
      }

      // Syllabic 'ん': write 'm' before b/p/m? Standard Hepburn uses 'n' (or n' before vowel/y).
      if (current == 'ん') {
        if (i + 1 < kana.length) {
          final nextRomaji = _matchKana(kana, i + 1).romaji;
          if (nextRomaji.isNotEmpty &&
              (_isVowel(nextRomaji[0]) || nextRomaji[0] == 'y')) {
            buffer.write("n'");
          } else {
            buffer.write('n');
          }
        } else {
          buffer.write('n');
        }
        i += 1;
        continue;
      }

      final match = _matchKana(kana, i);
      buffer.write(match.romaji);
      i += match.length;
    }

    return buffer.toString();
  }

  static ({String romaji, int length}) _matchKana(String kana, int index) {
    if (index + 1 < kana.length) {
      final two = kana.substring(index, index + 2);
      final digraph = _digraphMap[two];
      if (digraph != null) {
        return (romaji: digraph, length: 2);
      }
    }
    final one = kana[index];
    return (romaji: _monographMap[one] ?? one, length: 1);
  }

  static bool _isVowel(String ch) =>
      ch == 'a' || ch == 'i' || ch == 'u' || ch == 'e' || ch == 'o';

  static bool _isConsonant(String ch) => !_isVowel(ch) && ch != "'";

  static const Map<String, String> _digraphMap = {
    'きゃ': 'kya',
    'きゅ': 'kyu',
    'きょ': 'kyo',
    'ぎゃ': 'gya',
    'ぎゅ': 'gyu',
    'ぎょ': 'gyo',
    'しゃ': 'sha',
    'しゅ': 'shu',
    'しょ': 'sho',
    'じゃ': 'ja',
    'じゅ': 'ju',
    'じょ': 'jo',
    'ちゃ': 'cha',
    'ちゅ': 'chu',
    'ちょ': 'cho',
    'にゃ': 'nya',
    'にゅ': 'nyu',
    'にょ': 'nyo',
    'ひゃ': 'hya',
    'ひゅ': 'hyu',
    'ひょ': 'hyo',
    'びゃ': 'bya',
    'びゅ': 'byu',
    'びょ': 'byo',
    'ぴゃ': 'pya',
    'ぴゅ': 'pyu',
    'ぴょ': 'pyo',
    'みゃ': 'mya',
    'みゅ': 'myu',
    'みょ': 'myo',
    'りゃ': 'rya',
    'りゅ': 'ryu',
    'りょ': 'ryo',
  };

  static const Map<String, String> _monographMap = {
    'あ': 'a',
    'い': 'i',
    'う': 'u',
    'え': 'e',
    'お': 'o',
    'か': 'ka',
    'き': 'ki',
    'く': 'ku',
    'け': 'ke',
    'こ': 'ko',
    'が': 'ga',
    'ぎ': 'gi',
    'ぐ': 'gu',
    'げ': 'ge',
    'ご': 'go',
    'さ': 'sa',
    'し': 'shi',
    'す': 'su',
    'せ': 'se',
    'そ': 'so',
    'ざ': 'za',
    'じ': 'ji',
    'ず': 'zu',
    'ぜ': 'ze',
    'ぞ': 'zo',
    'た': 'ta',
    'ち': 'chi',
    'つ': 'tsu',
    'て': 'te',
    'と': 'to',
    'だ': 'da',
    'ぢ': 'ji',
    'づ': 'zu',
    'で': 'de',
    'ど': 'do',
    'な': 'na',
    'に': 'ni',
    'ぬ': 'nu',
    'ね': 'ne',
    'の': 'no',
    'は': 'ha',
    'ひ': 'hi',
    'ふ': 'fu',
    'へ': 'he',
    'ほ': 'ho',
    'ば': 'ba',
    'び': 'bi',
    'ぶ': 'bu',
    'べ': 'be',
    'ぼ': 'bo',
    'ぱ': 'pa',
    'ぴ': 'pi',
    'ぷ': 'pu',
    'ぺ': 'pe',
    'ぽ': 'po',
    'ま': 'ma',
    'み': 'mi',
    'む': 'mu',
    'め': 'me',
    'も': 'mo',
    'や': 'ya',
    'ゆ': 'yu',
    'よ': 'yo',
    'ら': 'ra',
    'り': 'ri',
    'る': 'ru',
    'れ': 're',
    'ろ': 'ro',
    'わ': 'wa',
    'を': 'o',
    'ー': '-',
  };
}
