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

  final FlutterTts _tts;

  @override
  Future<bool> initialize() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(false);
      final available = await _tts.isLanguageAvailable('ja-JP');
      if (available is bool) {
        return available;
      }
      if (available is num) {
        return available != 0;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> speak(String text, {bool slow = false}) async {
    try {
      await _tts.stop();
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
