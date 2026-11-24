import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:nihongo_tap/data/vocabulary_data.dart';
import 'package:nihongo_tap/models/word_entry.dart';
import 'package:nihongo_tap/services/speech_service.dart';
import 'package:nihongo_tap/services/update_service.dart';
import 'package:nihongo_tap/widgets/verb_conjugation_sheet.dart';
import 'package:nihongo_tap/widgets/word_tile.dart';

/// Main single-screen Japanese vocabulary list with tap-to-hear audio.
class WordListScreen extends StatefulWidget {
  const WordListScreen({
    super.key,
    required this.speechService,
    this.updateService,
    this.vocabulary = kVocabularyList,
  });

  final SpeechService speechService;
  final UpdateService? updateService;
  final List<WordEntry> vocabulary;

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  static const Color _indigo = Color(0xFF2B3A67);
  static const Color _mutedInk = Color(0xFF667085);

  FilterTab _selectedTab = FilterTab.everyday;
  ContextCategory? _selectedContext;
  bool _showRomaji = true;
  bool _slowSpeed = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String? _speakingWordId;
  bool _showTtsBanner = false;
  AppUpdateInfo? _availableUpdate;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  Timer? _speakingTimer;

  @override
  void initState() {
    super.initState();
    _initTts();
    _checkForUpdates();
  }

  Future<void> _initTts() async {
    final available = await widget.speechService.initialize();
    if (!mounted) return;
    if (!available) {
      setState(() => _showTtsBanner = true);
    }
  }

  Future<void> _checkForUpdates() async {
    final update = await widget.updateService?.checkForUpdate();
    if (!mounted || update == null) return;
    setState(() => _availableUpdate = update);
  }

  @override
  void dispose() {
    _speakingTimer?.cancel();
    _searchController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _resetListScroll() {
    if (_listScrollController.hasClients) {
      _listScrollController.jumpTo(0);
    }
  }

  Future<void> _speakWord(WordEntry word) async {
    _speakingTimer?.cancel();
    setState(() => _speakingWordId = word.id);
    _speakingTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _speakingWordId = null);
      }
    });
    await widget.speechService.speak(word.kana, slow: _slowSpeed);
  }

  Future<void> _speakText(String kanaText) async {
    await widget.speechService.speak(kanaText, slow: _slowSpeed);
  }

  void _openVerbSheet(WordEntry verb) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VerbConjugationSheet(
        verb: verb,
        showRomaji: _showRomaji,
        onSpeak: _speakText,
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = filterVocabulary(
      widget.vocabulary,
      _selectedTab,
      _searchQuery,
      context: _selectedContext,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search English, kana, romaji...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : const Text(
                'Nihongo Tap',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
        actions: [
          _HeaderTogglePill(
            label: 'Aa',
            tooltip: _showRomaji ? 'Hide romaji' : 'Show romaji',
            active: _showRomaji,
            onTap: () => setState(() => _showRomaji = !_showRomaji),
          ),
          const SizedBox(width: 6),
          _HeaderTogglePill(
            label: _slowSpeed ? '0.7×' : '1×',
            tooltip: _slowSpeed ? 'Normal speed' : 'Slow pronunciation',
            active: _slowSpeed,
            onTap: () => setState(() => _slowSpeed = !_slowSpeed),
          ),
          IconButton(
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Close search' : 'Search words',
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: FilterTab.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = FilterTab.values[index];
                final selected = tab == _selectedTab;
                return ChoiceChip(
                  label: Text(tab.label),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() => _selectedTab = tab);
                    _resetListScroll();
                  },
                  selectedColor: _indigo,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected ? _indigo : const Color(0xFFD0D5DD),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF344054),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_availableUpdate != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFEEF1F8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.system_update,
                    size: 18,
                    color: _indigo,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Update available (v${_availableUpdate!.versionName})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final url = _availableUpdate?.downloadUrl;
                      if (url != null) {
                        widget.updateService?.openDownloadUrl(url);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _indigo,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Download',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _availableUpdate = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          if (_showTtsBanner)
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF8EB),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF9A6700),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Japanese voice not detected. Enable Japanese in Android Settings → Text-to-speech.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5C3D00)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _showTtsBanner = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          _ContextFilterBar(
            selectedContext: _selectedContext,
            wordCount: words.length,
            onChanged: (value) {
              setState(() => _selectedContext = value);
              _resetListScroll();
            },
          ),
          Expanded(
            child: words.isEmpty
                ? const Center(
                    child: Text(
                      'No matching words found.',
                      style: TextStyle(fontSize: 15, color: _mutedInk),
                    ),
                  )
                : ListView.separated(
                    controller: _listScrollController,
                    itemCount: words.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      color: Color(0xFFEAECF0),
                    ),
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return WordTile(
                        key: ValueKey(word.id),
                        word: word,
                        showRomaji: _showRomaji,
                        isSpeaking: _speakingWordId == word.id,
                        onTap: () => _speakWord(word),
                        onShowConjugations: word.category == WordCategory.verb
                            ? () => _openVerbSheet(word)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTogglePill extends StatelessWidget {
  const _HeaderTogglePill({
    required this.label,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  static const Color _indigo = Color(0xFF2B3A67);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEEF1F8) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? _indigo : const Color(0xFFD0D5DD),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? _indigo : const Color(0xFF667085),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextFilterBar extends StatelessWidget {
  const _ContextFilterBar({
    required this.selectedContext,
    required this.wordCount,
    required this.onChanged,
  });

  final ContextCategory? selectedContext;
  final int wordCount;
  final ValueChanged<ContextCategory?> onChanged;

  static const Color _indigo = Color(0xFF2B3A67);
  static const Color _mutedInk = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    final isFiltered = selectedContext != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          bottom: BorderSide(color: Color(0xFFEAECF0)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: isFiltered ? const Color(0xFFEEF1F8) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isFiltered ? _indigo : const Color(0xFFD0D5DD),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ContextCategory?>(
                key: const Key('context_dropdown'),
                value: selectedContext,
                isDense: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isFiltered ? _indigo : _mutedInk,
                ),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isFiltered ? _indigo : const Color(0xFF344054),
                ),
                items: [
                  const DropdownMenuItem<ContextCategory?>(
                    value: null,
                    child: Text('All contexts'),
                  ),
                  for (final category in ContextCategory.values)
                    DropdownMenuItem<ContextCategory?>(
                      value: category,
                      child: Text('${category.label} · ${category.japaneseLabel}'),
                    ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$wordCount words',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _mutedInk,
            ),
          ),
        ],
      ),
    );
  }
}
