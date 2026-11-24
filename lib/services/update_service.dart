import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Metadata for a newer app release available on GitHub Releases.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.downloadUrl,
  });

  final String versionName;
  final int versionCode;
  final String downloadUrl;
}

/// Abstraction for checking and opening app updates so UI and tests stay decoupled.
abstract class UpdateService {
  /// Returns update info if a newer release is available, or `null` otherwise.
  Future<AppUpdateInfo?> checkForUpdate();

  /// Opens the release APK download [url] in the system browser/installer.
  Future<bool> openDownloadUrl(String url);
}

/// Checks GitHub Releases (`version.json`) and launches APK downloads via Android Intent.
class GitHubUpdateService implements UpdateService {
  GitHubUpdateService({Future<String?> Function(Uri uri)? fetchJson})
      : _fetchJson = fetchJson ?? _defaultFetchJson;

  static const String repoBaseUrl = 'https://github.com/radicelle/nihongo_tap';
  static const String latestVersionUrl =
      '$repoBaseUrl/releases/latest/download/version.json';
  static const MethodChannel channel = MethodChannel('nihongo_tap/updater');

  final Future<String?> Function(Uri uri) _fetchJson;

  static Future<String?> _defaultFetchJson(Uri uri) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 6);
    try {
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        return null;
      }
      return await response.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }

  /// Parses `version.json` from a GitHub Release into [AppUpdateInfo], or `null` if invalid.
  @visibleForTesting
  static AppUpdateInfo? parseLatestVersion(String jsonBody) {
    try {
      final decoded = jsonDecode(jsonBody);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final versionName = decoded['versionName'];
      final versionCode = decoded['versionCode'];
      final tag = decoded['tag'];
      final apk = decoded['apk'];

      if (versionName is! String || versionName.isEmpty) return null;
      if (versionCode is! int || versionCode <= 0) return null;
      if (tag is! String || tag.isEmpty) return null;
      if (apk is! String || apk.isEmpty || !apk.endsWith('.apk')) return null;

      return AppUpdateInfo(
        versionName: versionName,
        versionCode: versionCode,
        downloadUrl: '$repoBaseUrl/releases/download/$tag/$apk',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUpdateInfo?> checkForUpdate() async {
    int currentVersionCode;
    try {
      final versionInfo =
          await channel.invokeMethod<Map<dynamic, dynamic>>('getAppVersion');
      final rawCode = versionInfo?['versionCode'];
      if (rawCode is! int || rawCode <= 0) {
        return null;
      }
      currentVersionCode = rawCode;
    } catch (_) {
      return null;
    }

    try {
      final body = await _fetchJson(Uri.parse(latestVersionUrl));
      if (body == null || body.isEmpty) {
        return null;
      }
      final latest = parseLatestVersion(body);
      if (latest == null || latest.versionCode <= currentVersionCode) {
        return null;
      }
      return latest;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> openDownloadUrl(String url) async {
    try {
      final launched = await channel.invokeMethod<bool>('openUrl', url);
      return launched ?? false;
    } catch (_) {
      return false;
    }
  }
}
