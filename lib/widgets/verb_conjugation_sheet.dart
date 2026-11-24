import 'package:material_ui/material_ui.dart';
import 'package:nihongo_tap/models/word_entry.dart';
import 'package:nihongo_tap/services/verb_conjugator.dart';

/// Simple modal bottom sheet showing verb conjugations (with highlighted endings)
/// and tap-to-hear example sentences.
class VerbConjugationSheet extends StatefulWidget {
  const VerbConjugationSheet({
    super.key,
    required this.verb,
    required this.showRomaji,
    required this.onSpeak,
  });

  final WordEntry verb;
  final bool showRomaji;
  final Future<void> Function(String kanaText) onSpeak;

  @override
  State<VerbConjugationSheet> createState() => _VerbConjugationSheetState();
}

class _VerbConjugationSheetState extends State<VerbConjugationSheet> {
  static const Color _accentColor = Color(0xFFC84B31);
  static const Color _primaryInk = Color(0xFF1F2430);
  static const Color _mutedInk = Color(0xFF667085);
  static const Color _indigo = Color(0xFF2B3A67);

  String? _activeKey;

  Future<void> _speakItem(String key, String kanaText) async {
    setState(() => _activeKey = key);
    await widget.onSpeak(kanaText);
  }

  @override
  Widget build(BuildContext context) {
    final verb = widget.verb;
    final group = verb.verbGroup;
    final forms = VerbConjugator.conjugate(verb);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    // Header: verb + English + tap-to-hear button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (verb.hasDistinctKanji)
                                Text(
                                  verb.kana,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _mutedInk,
                                  ),
                                ),
                              Text(
                                verb.hasDistinctKanji ? verb.kanji : verb.kana,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryInk,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.showRomaji
                                    ? '${verb.romaji} · ${verb.english}'
                                    : verb.english,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: _mutedInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () => _speakItem('header', verb.kana),
                          style: IconButton.styleFrom(
                            backgroundColor: _activeKey == 'header'
                                ? const Color(0xFFFFE7E1)
                                : const Color(0xFFEEF1F8),
                            foregroundColor: _activeKey == 'header'
                                ? _accentColor
                                : _indigo,
                          ),
                          icon: const Icon(Icons.volume_up_rounded),
                          tooltip: 'Hear dictionary form',
                        ),
                      ],
                    ),
                    if (group != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              group.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _indigo,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                group.shortRule,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _mutedInk,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'Tap any form to hear it',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _mutedInk,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 6 Conjugation rows
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFEAECF0)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            for (var i = 0; i < forms.length; i++) ...[
                              if (i > 0)
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFEAECF0),
                                ),
                              _ConjugationRow(
                                form: forms[i],
                                showRomaji: widget.showRomaji,
                                showKanaSubline: verb.hasDistinctKanji,
                                isActive: _activeKey == 'form_$i',
                                onTap: () =>
                                    _speakItem('form_$i', forms[i].fullKana),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (verb.examples.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'How to use it',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _mutedInk,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (var i = 0; i < verb.examples.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        _ExampleCard(
                          example: verb.examples[i],
                          showRomaji: widget.showRomaji,
                          isActive: _activeKey == 'ex_$i',
                          onTap: () =>
                              _speakItem('ex_$i', verb.examples[i].kana),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConjugationRow extends StatelessWidget {
  const _ConjugationRow({
    required this.form,
    required this.showRomaji,
    required this.showKanaSubline,
    required this.isActive,
    required this.onTap,
  });

  final ConjugatedForm form;
  final bool showRomaji;
  final bool showKanaSubline;
  final bool isActive;
  final VoidCallback onTap;

  static const Color _accentColor = Color(0xFFC84B31);
  static const Color _primaryInk = Color(0xFF1F2430);
  static const Color _mutedInk = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFFFF5F2) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      form.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primaryInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      form.usageHint,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: form.stemKanji,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _primaryInk,
                            ),
                          ),
                          TextSpan(
                            text: form.endingKanji,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _accentColor,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.end,
                    ),
                    if (showKanaSubline && form.fullKanji != form.fullKana) ...[
                      const SizedBox(height: 1),
                      Text(
                        form.fullKana,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _mutedInk,
                        ),
                      ),
                    ],
                    if (showRomaji) ...[
                      const SizedBox(height: 1),
                      Text(
                        form.romaji,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _mutedInk,
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

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.example,
    required this.showRomaji,
    required this.isActive,
    required this.onTap,
  });

  final ExampleSentence example;
  final bool showRomaji;
  final bool isActive;
  final VoidCallback onTap;

  static const Color _accentColor = Color(0xFFC84B31);
  static const Color _primaryInk = Color(0xFF1F2430);
  static const Color _mutedInk = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFFFF5F2) : const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFEAECF0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                isActive ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                size: 18,
                color: isActive ? _accentColor : _mutedInk,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      example.japanese,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _primaryInk,
                      ),
                    ),
                    if (example.kana != example.japanese) ...[
                      const SizedBox(height: 2),
                      Text(
                        example.kana,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _mutedInk,
                        ),
                      ),
                    ],
                    if (showRomaji) ...[
                      const SizedBox(height: 2),
                      Text(
                        example.romaji,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _mutedInk,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      example.english,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _primaryInk,
                      ),
                    ),
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
