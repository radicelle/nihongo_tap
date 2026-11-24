/// Situational / lexical-field context categories for filtering vocabulary.
enum ContextCategory {
  wedding,
  restaurant,
  shop,
  train,
  party,
  cooking,
  school,
  hotel,
  travel,
  home,
  work,
  health,
  weather,
  social;

  String get label => switch (this) {
        ContextCategory.wedding => 'Wedding',
        ContextCategory.restaurant => 'Restaurant',
        ContextCategory.shop => 'Shop',
        ContextCategory.train => 'Train',
        ContextCategory.party => 'Party',
        ContextCategory.cooking => 'Cooking',
        ContextCategory.school => 'School',
        ContextCategory.hotel => 'Hotel',
        ContextCategory.travel => 'Travel',
        ContextCategory.home => 'Home',
        ContextCategory.work => 'Work',
        ContextCategory.health => 'Health',
        ContextCategory.weather => 'Weather',
        ContextCategory.social => 'Social',
      };

  String get japaneseLabel => switch (this) {
        ContextCategory.wedding => '結婚式',
        ContextCategory.restaurant => 'レストラン',
        ContextCategory.shop => '買い物',
        ContextCategory.train => '電車',
        ContextCategory.party => 'パーティー',
        ContextCategory.cooking => '料理',
        ContextCategory.school => '学校',
        ContextCategory.hotel => 'ホテル',
        ContextCategory.travel => '旅行',
        ContextCategory.home => '家',
        ContextCategory.work => '仕事',
        ContextCategory.health => '病院',
        ContextCategory.weather => '天気',
        ContextCategory.social => '挨拶',
      };
}

/// Categories of Japanese vocabulary in Nihongo Tap.
enum WordCategory {
  noun,
  verb,
  adjective,
  other;

  String get label => switch (this) {
        WordCategory.noun => 'Noun',
        WordCategory.verb => 'Verb',
        WordCategory.adjective => 'Adjective',
        WordCategory.other => 'Other',
      };

  String get japaneseLabel => switch (this) {
        WordCategory.noun => '名詞',
        WordCategory.verb => '動詞',
        WordCategory.adjective => '形容詞',
        WordCategory.other => 'その他',
      };
}

/// Top-level filter tabs in the word list.
enum FilterTab {
  everyday,
  nouns,
  verbs,
  adjectives,
  other;

  String get label => switch (this) {
        FilterTab.everyday => 'Everyday',
        FilterTab.nouns => 'Nouns',
        FilterTab.verbs => 'Verbs',
        FilterTab.adjectives => 'Adjectives',
        FilterTab.other => 'Other',
      };

  String get japaneseLabel => switch (this) {
        FilterTab.everyday => '毎日',
        FilterTab.nouns => '名詞',
        FilterTab.verbs => '動詞',
        FilterTab.adjectives => '形容詞',
        FilterTab.other => 'その他',
      };
}

/// Japanese verb conjugation groups.
enum VerbGroup {
  ichidan,
  godan,
  irregularSuru,
  irregularKuru;

  String get label => switch (this) {
        VerbGroup.ichidan => 'Ru-verb (Ichidan)',
        VerbGroup.godan => 'U-verb (Godan)',
        VerbGroup.irregularSuru => 'Irregular (する)',
        VerbGroup.irregularKuru => 'Irregular (来る)',
      };

  String get shortRule => switch (this) {
        VerbGroup.ichidan => 'Drop る and add the ending.',
        VerbGroup.godan => 'Change the final u-sound before adding the ending.',
        VerbGroup.irregularSuru => 'する changes to し / した / できる.',
        VerbGroup.irregularKuru => 'くる changes to き / こ.',
      };
}

/// Japanese adjective grammatical types.
enum AdjectiveType {
  iAdjective,
  naAdjective;

  String get badge => switch (this) {
        AdjectiveType.iAdjective => 'い',
        AdjectiveType.naAdjective => 'な',
      };
}

/// A short natural example sentence showing how a word is used.
class ExampleSentence {
  const ExampleSentence({
    required this.japanese,
    required this.kana,
    required this.romaji,
    required this.english,
  });

  final String japanese;
  final String kana;
  final String romaji;
  final String english;
}

/// A single vocabulary entry.
class WordEntry {
  const WordEntry({
    required this.id,
    required this.kanji,
    required this.kana,
    required this.romaji,
    required this.english,
    required this.category,
    this.contexts = const {},
    this.isEveryday = false,
    this.everydayRank = 999,
    this.verbGroup,
    this.adjectiveType,
    this.examples = const [],
  });

  final String id;
  final String kanji;
  final String kana;
  final String romaji;
  final String english;
  final WordCategory category;
  final Set<ContextCategory> contexts;
  final bool isEveryday;
  final int everydayRank;
  final VerbGroup? verbGroup;
  final AdjectiveType? adjectiveType;
  final List<ExampleSentence> examples;

  /// True when the entry has a Kanji representation distinct from Kana.
  bool get hasDistinctKanji => kanji.isNotEmpty && kanji != kana;
}

/// One conjugated form of a verb with stem/ending split for visual highlighting.
class ConjugatedForm {
  const ConjugatedForm({
    required this.label,
    required this.usageHint,
    required this.stemKana,
    required this.endingKana,
    required this.stemKanji,
    required this.endingKanji,
    required this.romaji,
  });

  final String label;
  final String usageHint;
  final String stemKana;
  final String endingKana;
  final String stemKanji;
  final String endingKanji;
  final String romaji;

  String get fullKana => '$stemKana$endingKana';
  String get fullKanji => '$stemKanji$endingKanji';
}
