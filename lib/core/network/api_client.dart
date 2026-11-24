import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import '../i18n/strings.dart';
import '../session/session_events.dart';
import 'api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/locale_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Thin wrapper over Dio with project conventions baked in.
///
/// - Bearer token attached automatically (when present).
/// - Accept-Language sent based on the user's selected app language.
/// - All transport / backend errors translated to {@link ApiException}.
class ApiClient {
  ApiClient(this._dio, {String Function()? networkMessage})
      : _networkMessage = networkMessage ?? (() => 'Şəbəkə xətası');

  final Dio _dio;
  final String Function() _networkMessage;

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

  Future<void> delete(String path, {Object? body, Options? options}) async {
    await _send<void>(
        () => _dio.delete<dynamic>(path, data: body, options: options));
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
    if (!kReleaseMode) {
      debugPrint('[net] ${e.requestOptions.method} ${e.requestOptions.uri} '
          'type=${e.type} status=${e.response?.statusCode} '
          'error=${e.error.runtimeType}: ${e.error}');
    }
    final Object? data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        code: (data['code'] as String?) ?? 'UNKNOWN',
        message: (data['message'] as String?) ?? _networkMessage(),
        status: e.response?.statusCode ?? 0,
        fields: _extractFieldErrors(data),
      );
    }
    // The server did answer, just not with our JSON (a proxy error page,
    // an empty body): that is a server problem, not the user's network.
    final int status = e.response?.statusCode ?? 0;
    if (status > 0) {
      return ApiException(
        code: 'HTTP_$status',
        message: _networkMessage(),
        status: status,
      );
    }
    // No answer at all: offline or timed out. Dio's own text is technical
    // English and must not reach the user.
    return ApiException(
      code: 'NETWORK',
      message: _networkMessage(),
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

/// Decodes a response body as UTF-8 without ever throwing.
///
/// A body with a stray non-UTF-8 byte (the server once sent its 401s as
/// ISO-8859-1) must still reach the interceptors: if decoding throws, Dio
/// drops the status code, the token refresh never runs and the user sees
/// "no internet" on every screen.
String lenientUtf8Decoder(
  List<int> bytes,
  RequestOptions options,
  ResponseBody body,
) =>
    utf8.decode(bytes, allowMalformed: true);

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
    responseDecoder: lenientUtf8Decoder,
  ));

  dio.interceptors.add(AuthInterceptor(tokens));
  dio.interceptors.add(LocaleInterceptor(ref));
  // First, so a dropped connection is retried before anything else
  // (including the token refresh) sees the error.
  dio.interceptors.insert(0, RetryInterceptor(dio));
  dio.interceptors.add(RefreshInterceptor(
    dio,
    tokens,
    onSessionExpired: ref.read(sessionEventsProvider).notifyExpired,
  ));

  return ApiClient(dio, networkMessage: () => ref.read(sProvider).networkError);
});
