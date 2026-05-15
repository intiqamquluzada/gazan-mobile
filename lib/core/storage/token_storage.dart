import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tiny abstraction over local key-value storage for auth tokens.
///
/// Implementation strategy:
/// - On native (iOS / Android / macOS / Windows / Linux) → encrypted
///   {@link FlutterSecureStorage} (keychain / keystore).
/// - On web → {@link SharedPreferences} (localStorage under the hood).
///   We don't use `flutter_secure_storage_web` because its WebCrypto-
///   based encryption requires a secure context (HTTPS or localhost),
///   and we serve over plain HTTP for the demo.
class TokenStorage {
  TokenStorage();

  static const String _kAccess = 'qazan.access_token';
  static const String _kRefresh = 'qazan.refresh_token';
  static const String _kExpires = 'qazan.access_expires_at';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiresAt,
  }) async {
    final String iso = accessExpiresAt.toUtc().toIso8601String();
    if (kIsWeb) {
      final SharedPreferences p = await _prefs;
      await p.setString(_kAccess, accessToken);
      await p.setString(_kRefresh, refreshToken);
      await p.setString(_kExpires, iso);
    } else {
      await _secure.write(key: _kAccess, value: accessToken);
      await _secure.write(key: _kRefresh, value: refreshToken);
      await _secure.write(key: _kExpires, value: iso);
    }
  }

  Future<String?> readAccessToken() async {
    if (kIsWeb) {
      final SharedPreferences p = await _prefs;
      return p.getString(_kAccess);
    }
    return _secure.read(key: _kAccess);
  }

  Future<String?> readRefreshToken() async {
    if (kIsWeb) {
      final SharedPreferences p = await _prefs;
      return p.getString(_kRefresh);
    }
    return _secure.read(key: _kRefresh);
  }

  Future<DateTime?> readAccessExpiresAt() async {
    String? raw;
    if (kIsWeb) {
      final SharedPreferences p = await _prefs;
      raw = p.getString(_kExpires);
    } else {
      raw = await _secure.read(key: _kExpires);
    }
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    if (kIsWeb) {
      final SharedPreferences p = await _prefs;
      await p.remove(_kAccess);
      await p.remove(_kRefresh);
      await p.remove(_kExpires);
    } else {
      await _secure.delete(key: _kAccess);
      await _secure.delete(key: _kRefresh);
      await _secure.delete(key: _kExpires);
    }
  }
}
