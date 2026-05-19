import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/locale_interceptor.dart';

/// Thin wrapper over Dio with project conventions baked in.
///
/// - Bearer token attached automatically (when present).
/// - Accept-Language sent based on the user's selected app language.
/// - All transport / backend errors translated to {@link ApiException}.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return _send<T>(() => _dio.get<dynamic>(
          path,
          queryParameters: query,
          options: options,
        ));
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return _send<T>(() => _dio.post<dynamic>(
          path,
          data: body,
          queryParameters: query,
          options: options,
        ));
  }

  Future<T> put<T>(
    String path, {
    Object? body,
    Options? options,
  }) async {
    return _send<T>(() => _dio.put<dynamic>(
          path,
          data: body,
          options: options,
        ));
  }

  Future<T> patch<T>(
    String path, {
    Object? body,
    Options? options,
  }) async {
    return _send<T>(() => _dio.patch<dynamic>(
          path,
          data: body,
          options: options,
        ));
  }

  Future<void> delete(String path, {Options? options}) async {
    await _send<void>(() => _dio.delete<dynamic>(path, options: options));
  }

  // ─────────────────────────── internals ───────────────────────────

  Future<T> _send<T>(Future<Response<dynamic>> Function() call) async {
    try {
      final Response<dynamic> res = await call();
      // ignore: avoid_dynamic_calls
      return res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final Object? data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        code: (data['code'] as String?) ?? 'UNKNOWN',
        message: (data['message'] as String?) ?? e.message ?? 'Xəta baş verdi',
        status: e.response?.statusCode ?? 0,
        fields: _extractFieldErrors(data),
      );
    }
    return ApiException(
      code: 'NETWORK',
      message: e.message ?? 'Şəbəkə xətası',
      status: e.response?.statusCode ?? 0,
    );
  }

  Map<String, String> _extractFieldErrors(Map<String, dynamic> body) {
    final Object? raw = body['fields'];
    if (raw is! List) return const <String, String>{};
    final Map<String, String> result = <String, String>{};
    for (final Object? item in raw) {
      if (item is Map<String, dynamic>) {
        final String? field = item['field'] as String?;
        final String? msg = item['message'] as String?;
        if (field != null && msg != null) result[field] = msg;
      }
    }
    return result;
  }
}

// ─────────────────────────── providers ───────────────────────────

final Provider<TokenStorage> tokenStorageProvider =
    Provider<TokenStorage>((Ref ref) => TokenStorage());

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  final TokenStorage tokens = ref.read(tokenStorageProvider);

  final Dio dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    contentType: 'application/json',
    responseType: ResponseType.json,
    validateStatus: (int? code) => code != null && code >= 200 && code < 300,
  ));

  dio.interceptors.add(AuthInterceptor(tokens));
  dio.interceptors.add(LocaleInterceptor(ref));

  return ApiClient(dio);
});
