import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

/// Uploads images to the backend (`POST /api/v1/images`) and returns an
/// absolute URL the company profile can store and `<img>` can render.
class MediaRepository {
  MediaRepository(this._api);

  final ApiClient _api;

  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
    String contentType = 'image/jpeg',
  }) async {
    final List<String> ct = contentType.split('/');
    final FormData form = FormData.fromMap(<String, dynamic>{
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType(
          ct.first,
          ct.length > 1 ? ct[1] : 'jpeg',
        ),
      ),
    });

    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/images',
      body: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    final String path = (json['url'] as String?) ?? '';
    // Store the absolute URL so cached_network_image can load it directly.
    return path.startsWith('http')
        ? path
        : '${AppConfig.apiBaseUrl}$path';
  }
}

final Provider<MediaRepository> mediaRepositoryProvider =
    Provider<MediaRepository>(
  (Ref ref) => MediaRepository(ref.read(apiClientProvider)),
);
