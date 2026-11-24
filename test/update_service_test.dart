import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_tap/services/update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(GitHubUpdateService.channel, null);
  });

  test('parseLatestVersion parses valid version.json payload', () {
    final info = GitHubUpdateService.parseLatestVersion('''
      {
        "versionName": "1.0.5",
        "versionCode": 5,
        "apk": "nihongo-tap-v1.0.5.apk",
        "tag": "v1.0.5"
      }
    ''');

    expect(info, isNotNull);
    expect(info!.versionName, '1.0.5');
    expect(info.versionCode, 5);
    expect(
      info.downloadUrl,
      'https://github.com/radicelle/nihongo_tap/releases/download/v1.0.5/nihongo-tap-v1.0.5.apk',
    );
  });

  test('parseLatestVersion returns null on malformed or incomplete JSON', () {
    expect(GitHubUpdateService.parseLatestVersion('not json'), isNull);
    expect(
      GitHubUpdateService.parseLatestVersion('{"versionName": "1.0.5"}'),
      isNull,
    );
    expect(
      GitHubUpdateService.parseLatestVersion(
        '{"versionName": "1.0.5", "versionCode": 0, "apk": "app.apk", "tag": "v1.0.5"}',
      ),
      isNull,
    );
    expect(
      GitHubUpdateService.parseLatestVersion(
        '{"versionName": "1.0.5", "versionCode": 5, "apk": "app.txt", "tag": "v1.0.5"}',
      ),
      isNull,
    );
  });

  test('checkForUpdate returns update info when remote versionCode is higher', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(GitHubUpdateService.channel, (call) async {
          if (call.method == 'getAppVersion') {
            return {'versionName': '1.0.3', 'versionCode': 3};
          }
          return null;
        });

    Uri? requestedUri;
    final service = GitHubUpdateService(
      fetchJson: (uri) async {
        requestedUri = uri;
        return '{"versionName":"1.0.5","versionCode":5,"apk":"nihongo-tap-v1.0.5.apk","tag":"v1.0.5"}';
      },
    );

    final update = await service.checkForUpdate();

    expect(
      requestedUri.toString(),
      GitHubUpdateService.latestVersionUrl,
    );
    expect(update, isNotNull);
    expect(update!.versionName, '1.0.5');
    expect(update.versionCode, 5);
  });

  test('checkForUpdate returns null when already up to date', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(GitHubUpdateService.channel, (call) async {
          if (call.method == 'getAppVersion') {
            return {'versionName': '1.0.5', 'versionCode': 5};
          }
          return null;
        });

    final service = GitHubUpdateService(
      fetchJson: (_) async =>
          '{"versionName":"1.0.5","versionCode":5,"apk":"nihongo-tap-v1.0.5.apk","tag":"v1.0.5"}',
    );

    expect(await service.checkForUpdate(), isNull);
  });

  test('checkForUpdate returns null when getAppVersion fails or fetch throws', () async {
    final serviceWithoutVersion = GitHubUpdateService(
      fetchJson: (_) async {
        fail('fetchJson should not be called when app version is unavailable');
      },
    );
    expect(await serviceWithoutVersion.checkForUpdate(), isNull);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(GitHubUpdateService.channel, (call) async {
          if (call.method == 'getAppVersion') {
            return {'versionName': '1.0.1', 'versionCode': 1};
          }
          return null;
        });

    final serviceWithNetworkError = GitHubUpdateService(
      fetchJson: (_) async => throw Exception('offline'),
    );
    expect(await serviceWithNetworkError.checkForUpdate(), isNull);
  });

  test('openDownloadUrl invokes openUrl on MethodChannel', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(GitHubUpdateService.channel, (call) async {
          calls.add(call);
          return call.method == 'openUrl';
        });

    final service = GitHubUpdateService();
    const apkUrl =
        'https://github.com/radicelle/nihongo_tap/releases/download/v1.0.5/nihongo-tap-v1.0.5.apk';

    final opened = await service.openDownloadUrl(apkUrl);

    expect(opened, isTrue);
    expect(calls, hasLength(1));
    expect(calls.single.method, 'openUrl');
    expect(calls.single.arguments, apkUrl);
  });
}
