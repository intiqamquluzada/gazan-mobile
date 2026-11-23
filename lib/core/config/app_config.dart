import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Runtime configuration. Override the base URL with
/// `flutter run --dart-define=API_BASE_URL=https://api.qazan.app`.
class AppConfig {
  const AppConfig._();

  /// Backend that shipped artefacts (APK / App Bundle / web) talk to.
  /// HTTPS only: release builds allow no cleartext traffic (Android
  /// manifest, iOS ATS defaults).
  static const String _productionBaseUrl = 'https://api.qazan.app';

  /// Base URL of the backend API.
  static const String _override =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    // localhost / 10.0.2.2 only exist on a developer machine, so they must
    // never be the fallback for a build that runs on a real device.
    if (kReleaseMode) return _productionBaseUrl;
    if (kIsWeb) return 'http://localhost:8080';
    // Android emulator routes the host machine through 10.0.2.2.
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    // iOS Simulator + macOS desktop see localhost as the host machine.
    return 'http://localhost:8080';
  }

  /// Our image endpoint, wherever the API happens to be hosted.
  static const String _imagePath = '/api/v1/images/';

  /// Turns a stored image reference into a loadable URL. Paths are relative
  /// to the API, and older rows hold absolute URLs of a previous host, so
  /// both are re-based on the current server. Foreign URLs pass through.
  static String mediaUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('/')) return '$apiBaseUrl$url';
    final int i = url.indexOf(_imagePath);
    return i > 0 ? '$apiBaseUrl${url.substring(i)}' : sizedUnsplash(url);
  }

  /// Widest image a phone screen needs (about 3x a full-width card).
  static const int _maxImageWidth = 1000;

  /// Unsplash serves the full-resolution original (often 2+ MB) unless the
  /// URL asks for a size. Cap the width and let it pick a compact format,
  /// which makes the same photo roughly 15-20 times smaller.
  @visibleForTesting
  static String sizedUnsplash(String url) {
    final Uri? u = Uri.tryParse(url);
    if (u == null || u.host != 'images.unsplash.com') return url;
    final Map<String, String> q = Map<String, String>.of(u.queryParameters);
    final int? w = int.tryParse(q['w'] ?? '');
    q['w'] = '${w == null || w > _maxImageWidth ? _maxImageWidth : w}';
    q.putIfAbsent('q', () => '70');
    q['auto'] = 'format';
    q.putIfAbsent('fit', () => 'crop');
    return u.replace(queryParameters: q).toString();
  }

  static String? mediaUrlOrNull(String? url) =>
      url == null ? null : mediaUrl(url);

  /// The host-independent form saved to the server.
  static String storedMediaUrl(String url) {
    final int i = url.indexOf(_imagePath);
    return i > 0 ? url.substring(i) : url;
  }

  /// Google's OAuth client of type "Web"; its ID is the token audience the
  /// backend verifies. Empty hides the Google button.
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID',
          defaultValue:
              '201188254579-4dm34cth1fv5i9lj6pac999b89hv74gp.apps.googleusercontent.com');

  /// iOS OAuth client (only needed for Google sign-in on iPhone).
  static const String googleIosClientId =
      String.fromEnvironment('GOOGLE_IOS_CLIENT_ID',
          defaultValue:
              '201188254579-tvg2reerpoegenqdkl3om48qf1e8hure.apps.googleusercontent.com');

  /// Public legal pages (privacy policy, terms, account deletion) served by
  /// the backend. Override with `--dart-define=LEGAL_BASE_URL=...` once they
  /// live on the website.
  static const String _legalOverride =
      String.fromEnvironment('LEGAL_BASE_URL', defaultValue: '');

  static String get legalBaseUrl =>
      _legalOverride.isNotEmpty ? _legalOverride : '$apiBaseUrl/legal';

  /// e.g. legalUrl('privacy', 'tr') → …/legal/privacy?lang=tr
  static String legalUrl(String page, String lang) =>
      '$legalBaseUrl/$page?lang=$lang';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
