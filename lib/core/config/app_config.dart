import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Runtime configuration. Override the base URL with
/// `flutter run --dart-define=API_BASE_URL=https://api.qazan.az`.
class AppConfig {
  const AppConfig._();

  /// Base URL of the backend API.
  static const String _override =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://localhost:8080';
    // Android emulator routes the host machine through 10.0.2.2.
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    // iOS Simulator + macOS desktop see localhost as the host machine.
    return 'http://localhost:8080';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
