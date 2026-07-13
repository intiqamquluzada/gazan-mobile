import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Runtime configuration. Override the base URL with
/// `flutter run --dart-define=API_BASE_URL=https://api.qazan.az`.
class AppConfig {
  const AppConfig._();

  /// Backend that shipped artefacts (APK / App Bundle / web) talk to.
  /// Plain HTTP: the server has no TLS on 443 yet, which is why
  /// `usesCleartextTraffic` is still enabled in AndroidManifest.xml.
  static const String _productionBaseUrl = 'http://46.36.201.105';

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

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
