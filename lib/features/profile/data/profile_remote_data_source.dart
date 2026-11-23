import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/auth_remote_data_source.dart';
import '../../auth/domain/app_user.dart';

/// Wraps `/api/v1/users/me` endpoints used by the profile screen.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._api);

  final ApiClient _api;

  Future<AppUser> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? businessName,
    String? locale,
    DateTime? birthDate,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (avatarUrl != null) {
      body['avatarUrl'] = AppConfig.storedMediaUrl(avatarUrl);
    }
    if (birthDate != null) {
      body['birthDate'] = birthDate.toIso8601String().split('T').first;
    }
    if (businessName != null) body['businessName'] = businessName;
    if (locale != null) body['locale'] = locale;

    final Map<String, dynamic> json =
        await _api.put<Map<String, dynamic>>('/api/v1/users/me', body: body);
    return AuthRemoteDataSource.userFromJson(json);
  }

  /// Removes the profile photo (the server treats an empty value as "none").
  Future<AppUser> removeAvatar() async {
    final Map<String, dynamic> json = await _api.put<Map<String, dynamic>>(
      '/api/v1/users/me',
      body: <String, dynamic>{'avatarUrl': ''},
    );
    return AuthRemoteDataSource.userFromJson(json);
  }

  /// The server signs out every other device and hands this one a fresh
  /// session; returns its JSON (`accessToken`, `refreshToken`, `user`), or
  /// null from an older server that only answers "OK".
  Future<Map<String, dynamic>?> changePassword({
    String? currentPassword,
    required String newPassword,
  }) async {
    final Object? res = await _api.post<dynamic>(
      '/api/v1/users/me/change-password',
      body: <String, dynamic>{
        if (currentPassword != null) 'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    if (res is Map<String, dynamic> && res['accessToken'] is String) return res;
    return null;
  }

  /// Saves the push switches on the server, which decides what to send.
  Future<AppUser> updateNotificationPrefs(Map<String, bool> prefs) async {
    final Map<String, dynamic> json = await _api.put<Map<String, dynamic>>(
      '/api/v1/users/me/notification-prefs',
      body: prefs,
    );
    return AuthRemoteDataSource.userFromJson(json);
  }

  /// Permanently deletes the signed-in account (anonymized server-side,
  /// all sessions revoked). After this the caller must clear local state.
  Future<void> deleteAccount() async {
    await _api.delete('/api/v1/users/me');
  }
}

final Provider<ProfileRemoteDataSource> profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>(
  (Ref ref) => ProfileRemoteDataSource(ref.read(apiClientProvider)),
);
