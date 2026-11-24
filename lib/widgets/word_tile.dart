import 'package:material_ui/material_ui.dart';
import 'package:nihongo_tap/models/word_entry.dart';

/// A clean, spacious word row that speaks on tap.
class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.word,
    required this.showRomaji,
    required this.isSpeaking,
    required this.onTap,
    this.onShowConjugations,
  });

  final WordEntry word;
  final bool showRomaji;
  final bool isSpeaking;
  final VoidCallback onTap;
  final VoidCallback? onShowConjugations;

  static const Color _accentColor = Color(0xFFC84B31);
  static const Color _primaryInk = Color(0xFF1F2430);
  static const Color _mutedInk = Color(0xFF667085);
  static const Color _indigo = Color(0xFF2B3A67);

  @override
  Widget build(BuildContext context) {
    final adjType = word.adjectiveType;

    return Material(
      color: isSpeaking ? const Color(0xFFFFF5F2) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                size: 20,
                color: isSpeaking ? _accentColor : _mutedInk,
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (word.hasDistinctKanji) ...[
                      Text(
                        word.kana,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _mutedInk,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        word.kanji,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: _primaryInk,
                          height: 1.2,
                        ),
                      ),
                    ] else
                      Text(
                        word.kana,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: _primaryInk,
                          height: 1.25,
                        ),
                      ),
                    if (showRomaji) ...[
                      const SizedBox(height: 3),
                      Text(
                        word.romaji,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _mutedInk,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (adjType != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF1F8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              adjType.badge,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _indigo,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            word.english,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 15,
                              color: _primaryInk,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (word.category == WordCategory.verb &&
                        onShowConjugations != null) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: onShowConjugations,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _indigo,
                          side: const BorderSide(color: Color(0xFFD0D7E6)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Forms',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
