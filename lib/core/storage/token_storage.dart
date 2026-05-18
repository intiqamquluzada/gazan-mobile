import 'package:shared_preferences/shared_preferences.dart';

/// Tiny abstraction over local key-value storage for auth tokens.
///
/// Backed by {@link SharedPreferences} on every platform — works on
/// HTTP, HTTPS, web, iOS, Android, macOS. Tokens are NOT encrypted;
/// for a production app that handles PII, swap in
/// `flutter_secure_storage` on native and HttpOnly cookies on web.
class TokenStorage {
  TokenStorage();

  static const String _kAccess = 'qazan.access_token';
  static const String _kRefresh = 'qazan.refresh_token';
  static const String _kExpires = 'qazan.access_expires_at';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiresAt,
  }) async {
    final SharedPreferences p = await _prefs;
    await p.setString(_kAccess, accessToken);
    await p.setString(_kRefresh, refreshToken);
    await p.setString(_kExpires, accessExpiresAt.toUtc().toIso8601String());
  }

  Future<String?> readAccessToken() async {
    final SharedPreferences p = await _prefs;
    return p.getString(_kAccess);
  }

  Future<String?> readRefreshToken() async {
    final SharedPreferences p = await _prefs;
    return p.getString(_kRefresh);
  }

  Future<DateTime?> readAccessExpiresAt() async {
    final SharedPreferences p = await _prefs;
    final String? raw = p.getString(_kExpires);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    final SharedPreferences p = await _prefs;
    await p.remove(_kAccess);
    await p.remove(_kRefresh);
    await p.remove(_kExpires);
  }
}
