import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    if (businessName != null) body['businessName'] = businessName;
    if (locale != null) body['locale'] = locale;

    final Map<String, dynamic> json =
        await _api.put<Map<String, dynamic>>('/api/v1/users/me', body: body);
    return AuthRemoteDataSource.userFromJson(json);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.post<dynamic>(
      '/api/v1/users/me/change-password',
      body: <String, dynamic>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}

final Provider<ProfileRemoteDataSource> profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>(
  (Ref ref) => ProfileRemoteDataSource(ref.read(apiClientProvider)),
);
