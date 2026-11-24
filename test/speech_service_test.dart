import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_tap/services/speech_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_tts');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('selectBestJapaneseVoice picks local high-quality ja-JP voice', () {
    final selected = FlutterTtsSpeechService.selectBestJapaneseVoice([
      {
        'name': 'fr-fr-x-fra-local',
        'locale': 'fr-FR',
        'quality': 'very high',
        'network_required': '0',
        'features': '',
      },
      {
        'name': 'ja-jp-x-uninstalled',
        'locale': 'ja-JP',
        'quality': 'very high',
        'network_required': '0',
        'features': 'notInstalled',
      },
      {
        'name': 'ja-jp-x-network',
        'locale': 'ja-JP',
        'quality': 'very high',
        'network_required': '1',
        'features': '',
      },
      {
        'name': 'ja-x-low-local',
        'locale': 'ja',
        'quality': 'low',
        'network_required': '0',
        'features': '',
      },
      {
        'name': 'ja-jp-x-jac-local',
        'locale': 'ja-JP',
        'quality': 'normal',
        'network_required': '0',
        'features': '',
      },
      {
        'name': 'ja-jp-x-jad-local',
        'locale': 'ja-JP',
        'quality': 'very high',
        'network_required': '0',
        'features': '',
      },
    ]);

    expect(selected, {'name': 'ja-jp-x-jad-local', 'locale': 'ja-JP'});
  });

  test(
    'initialize checks availability before applying Japanese language and voice',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            switch (call.method) {
              case 'isLanguageAvailable':
                return call.arguments == 'ja-JP';
              case 'getVoices':
                return [
                  {
                    'name': 'fr-fr-x-fra-local',
                    'locale': 'fr-FR',
                    'quality': 'high',
                    'network_required': '0',
                    'features': '',
                  },
                  {
                    'name': 'ja-jp-x-jad-local',
                    'locale': 'ja-JP',
                    'quality': 'high',
                    'network_required': '0',
                    'features': '',
                  },
                ];
              default:
                return 1;
            }
          });

      final service = FlutterTtsSpeechService();
      final available = await service.initialize();

      expect(available, isTrue);

      final methodNames = calls.map((c) => c.method).toList();
      final availabilityIndex = methodNames.indexOf('isLanguageAvailable');
      final setLanguageIndex = methodNames.indexOf('setLanguage');
      final setVoiceIndex = methodNames.indexOf('setVoice');

      expect(availabilityIndex, isNonNegative);
      expect(setLanguageIndex, greaterThan(availabilityIndex));
      expect(setVoiceIndex, greaterThan(setLanguageIndex));

      expect(calls[setLanguageIndex].arguments, 'ja-JP');
      expect(calls[setVoiceIndex].arguments, {
        'name': 'ja-jp-x-jad-local',
        'locale': 'ja-JP',
      });
    },
  );

  test(
    'speak re-applies Japanese language and voice before every utterance',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            switch (call.method) {
              case 'isLanguageAvailable':
                return call.arguments == 'ja-JP';
              case 'getVoices':
                return [
                  {
                    'name': 'ja-jp-x-jad-local',
                    'locale': 'ja-JP',
                    'quality': 'high',
                    'network_required': '0',
                    'features': '',
                  },
                ];
              default:
                return 1;
            }
          });

      final service = FlutterTtsSpeechService();
      await service.initialize();
      calls.clear();

      await service.speak('ありがとう');
      await service.speak('すみません', slow: true);

      final firstSpeakIndex = calls.indexWhere((c) => c.method == 'speak');
      expect(firstSpeakIndex, isNonNegative);

      final beforeFirstSpeak = calls.sublist(0, firstSpeakIndex);
      expect(
        beforeFirstSpeak.any(
          (c) => c.method == 'setLanguage' && c.arguments == 'ja-JP',
        ),
        isTrue,
      );
      expect(
        beforeFirstSpeak.any(
          (c) =>
              c.method == 'setVoice' &&
              c.arguments['name'] == 'ja-jp-x-jad-local',
        ),
        isTrue,
      );
      expect(
        beforeFirstSpeak.any(
          (c) => c.method == 'setSpeechRate' && c.arguments == 0.48,
        ),
        isTrue,
      );

      final secondSpeakIndex = calls.lastIndexWhere((c) => c.method == 'speak');
      expect(secondSpeakIndex, greaterThan(firstSpeakIndex));

      final betweenSpeaks = calls.sublist(firstSpeakIndex + 1, secondSpeakIndex);
      expect(
        betweenSpeaks.any(
          (c) => c.method == 'setLanguage' && c.arguments == 'ja-JP',
        ),
        isTrue,
      );
      expect(
        betweenSpeaks.any(
          (c) =>
              c.method == 'setVoice' &&
              c.arguments['name'] == 'ja-jp-x-jad-local',
        ),
        isTrue,
      );
      expect(
        betweenSpeaks.any(
          (c) => c.method == 'setSpeechRate' && c.arguments == 0.32,
        ),
        isTrue,
      );
    },
  );

  test(
    'initialize falls back to Google TTS engine when default lacks Japanese',
    () async {
      final calls = <MethodCall>[];
      var currentEngine = 'com.example.french_only_tts';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            switch (call.method) {
              case 'isLanguageAvailable':
                return currentEngine == 'com.google.android.tts' &&
                    call.arguments == 'ja-JP';
              case 'getVoices':
                if (currentEngine == 'com.google.android.tts') {
                  return [
                    {
                      'name': 'ja-jp-x-jab-local',
                      'locale': 'ja-JP',
                      'quality': 'high',
                      'network_required': '0',
                      'features': '',
                    },
                  ];
                }
                return [
                  {
                    'name': 'fr-fr-x-fra-local',
                    'locale': 'fr-FR',
                    'quality': 'high',
                    'network_required': '0',
                    'features': '',
                  },
                ];
              case 'getEngines':
                return [
                  'com.example.french_only_tts',
                  'com.google.android.tts',
                ];
              case 'getDefaultEngine':
                return 'com.example.french_only_tts';
              case 'setEngine':
                currentEngine = call.arguments as String;
                return 1;
              default:
                return 1;
            }
          });

      final service = FlutterTtsSpeechService();
      final available = await service.initialize();

      expect(available, isTrue);
      expect(
        calls.any(
          (c) =>
              c.method == 'setEngine' &&
              c.arguments == 'com.google.android.tts',
        ),
        isTrue,
      );
      expect(
        calls.any(
          (c) => c.method == 'setLanguage' && c.arguments == 'ja-JP',
        ),
        isTrue,
      );
      expect(
        calls.any(
          (c) =>
              c.method == 'setVoice' &&
              c.arguments['name'] == 'ja-jp-x-jab-local',
        ),
        isTrue,
      );
    },
  );

  test('initialize returns false when no engine supports Japanese', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'isLanguageAvailable':
              return false;
            case 'getVoices':
              return [
                {
                  'name': 'fr-fr-x-fra-local',
                  'locale': 'fr-FR',
                  'quality': 'high',
                  'network_required': '0',
                  'features': '',
                },
              ];
            case 'getEngines':
              return ['com.example.french_only_tts'];
            case 'getDefaultEngine':
              return 'com.example.french_only_tts';
            default:
              return 1;
          }
        });

    final service = FlutterTtsSpeechService();
    final available = await service.initialize();

    expect(available, isFalse);
  });
}
