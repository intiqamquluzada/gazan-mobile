import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/app_user.dart';
import '../domain/role_mapping.dart';
import '../domain/user_role.dart';

/// Result of a successful auth call: tokens + the user profile.
class AuthSession {
  const AuthSession({required this.user, required this.expiresAt});

  final AppUser user;
  final DateTime expiresAt;
}

/// Talks to the backend's `/auth/*` endpoints. Persists tokens via
/// {@link TokenStorage} but does not own session state — the controller does.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String locale = 'AZ',
  }) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/auth/register',
      body: <String, dynamic>{
        'email': email.trim(),
        'password': password,
        'fullName': fullName.trim(),
        'phone': phone,
        'role': RoleMapping.toBackend(role),
        'locale': locale,
      },
    );
    return _consume(json);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      body: <String, dynamic>{'email': email.trim(), 'password': password},
    );
    return _consume(json);
  }

  Future<void> logout() async {
    final String? refresh = await _tokens.readRefreshToken();
    if (refresh != null) {
      try {
        await _api.post<dynamic>(
          '/api/v1/auth/logout',
          body: <String, dynamic>{'refreshToken': refresh},
        );
      } catch (_) {
        // Logout is best-effort — clearing local tokens always succeeds.
      }
    }
    await _tokens.clear();
  }

  Future<AppUser> me() async {
    final Map<String, dynamic> json =
        await _api.get<Map<String, dynamic>>('/api/v1/users/me');
    return _userFromJson(json);
  }

  // ───────────────────────── helpers ────────────────────────

  Future<AuthSession> _consume(Map<String, dynamic> json) async {
    final DateTime expiresAt =
        DateTime.parse(json['accessExpiresAt'] as String).toUtc();
    await _tokens.save(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessExpiresAt: expiresAt,
    );
    final AppUser user =
        _userFromJson(json['user'] as Map<String, dynamic>);
    return AuthSession(user: user, expiresAt: expiresAt);
  }

  /// Public entry point — also used by the profile feature when it
  /// receives an updated user from `PUT /users/me`.
  static AppUser userFromJson(Map<String, dynamic> json) => _userFromJson(json);

  static AppUser _userFromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      fullName: (json['fullName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: RoleMapping.fromBackend((json['role'] as String?) ?? 'CUSTOMER'),
      businessId: null,
    );
  }
}

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>(
  (Ref ref) => AuthRemoteDataSource(
    ref.read(apiClientProvider),
    ref.read(tokenStorageProvider),
  ),
);
