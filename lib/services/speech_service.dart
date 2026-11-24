import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Abstraction over Japanese text-to-speech playback so UI and tests stay decoupled.
abstract class SpeechService {
  /// Initializes the TTS engine and returns `true` if Japanese is available.
  Future<bool> initialize();

  /// Speaks [text] immediately in Japanese, optionally at a [slow] pace.
  Future<void> speak(String text, {bool slow = false});

  /// Stops any currently playing speech.
  Future<void> stop();

  /// Releases any engine resources.
  void dispose();
}

/// Android / mobile text-to-speech implementation backed by `flutter_tts`.
class FlutterTtsSpeechService implements SpeechService {
  FlutterTtsSpeechService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  static const List<String> _japaneseLocales = ['ja-JP', 'ja'];
  static const String _googleTtsEngine = 'com.google.android.tts';

  final FlutterTts _tts;
  String _locale = 'ja-JP';
  Map<String, String>? _selectedVoice;
  bool _initialized = false;

  /// Picks the highest-scoring installed Japanese voice from `flutter_tts.getVoices`.
  @visibleForTesting
  static Map<String, String>? selectBestJapaneseVoice(dynamic rawVoices) {
    if (rawVoices is! List) {
      return null;
    }

    Map<String, String>? bestVoice;
    var bestScore = -1;

    for (final entry in rawVoices) {
      if (entry is! Map) continue;

      final name = entry['name']?.toString() ?? '';
      final locale = entry['locale']?.toString() ?? '';
      if (name.isEmpty || locale.isEmpty) continue;

      final normalizedLocale = locale.toLowerCase();
      final isJapanese = normalizedLocale == 'ja' ||
          normalizedLocale.startsWith('ja-') ||
          normalizedLocale.startsWith('ja_');
      if (!isJapanese) continue;

      final features = entry['features']?.toString().toLowerCase() ?? '';
      if (features.contains('notinstalled')) continue;

      var score = 0;
      if (entry['network_required']?.toString() != '1') {
        score += 100;
      }
      if (normalizedLocale == 'ja-jp') {
        score += 20;
      }

      switch (entry['quality']?.toString().toLowerCase()) {
        case 'very high':
          score += 5;
        case 'high':
          score += 4;
        case 'normal':
          score += 3;
        case 'low':
          score += 2;
        case 'very low':
          score += 1;
      }

      if (score > bestScore) {
        bestScore = score;
        bestVoice = {'name': name, 'locale': locale};
      }
    }

    return bestVoice;
  }

  bool _isTruthy(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }

  Future<void> _applyJapaneseVoice() async {
    await _tts.setLanguage(_locale);
    if (_selectedVoice != null) {
      await _tts.setVoice(_selectedVoice!);
    }
  }

  Future<bool> _configureJapanese() async {
    String? matchedLocale;
    for (final locale in _japaneseLocales) {
      if (_isTruthy(await _tts.isLanguageAvailable(locale))) {
        matchedLocale = locale;
        break;
      }
    }

    Map<String, String>? bestVoice;
    try {
      final voices = await _tts.getVoices;
      bestVoice = selectBestJapaneseVoice(voices);
    } catch (_) {
      // Some platforms or engines do not expose voice enumeration.
    }

    if (matchedLocale == null && bestVoice == null) {
      return false;
    }

    _locale = matchedLocale ?? bestVoice?['locale'] ?? 'ja-JP';
    _selectedVoice = bestVoice;
    await _applyJapaneseVoice();
    return true;
  }

  @override
  Future<bool> initialize() async {
    try {
      var available = await _configureJapanese();

      if (!available) {
        try {
          final engines = await _tts.getEngines;
          final defaultEngine = await _tts.getDefaultEngine;
          if (engines is List &&
              engines.contains(_googleTtsEngine) &&
              defaultEngine != _googleTtsEngine) {
            await _tts.setEngine(_googleTtsEngine);
            available = await _configureJapanese();
          }
        } catch (_) {
          // Ignore engine fallback errors on unsupported platforms.
        }
      }

      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(false);

      if (available) {
        await _applyJapaneseVoice();
        _initialized = true;
      }

      return available;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> speak(String text, {bool slow = false}) async {
    try {
      if (!_initialized) {
        await initialize();
      }
      await _tts.stop();
      await _applyJapaneseVoice();
      await _tts.setSpeechRate(slow ? 0.32 : 0.48);
      await _tts.speak(text);
    } catch (_) {
      // Ignore transient platform TTS errors so tapping never crashes the UI.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignore stop errors.
    }
  }

  @override
  void dispose() {
    _tts.stop();
  }
}
