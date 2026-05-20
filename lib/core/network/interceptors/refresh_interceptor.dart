import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

/// Transparently refreshes an expired access token.
///
/// When any non-auth request comes back `401`, this interceptor:
///   1. Calls `/api/v1/auth/refresh` with the stored refresh token.
///   2. Persists the new token pair.
///   3. Retries the original request once.
///
/// Concurrency-safe: if several requests 401 at the same time, they all
/// await the *same* refresh call instead of hammering the endpoint.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor(this._dio, this._tokens);

  final Dio _dio;
  final TokenStorage _tokens;

  /// In-flight refresh, shared by every caller until it completes.
  Future<bool>? _refreshing;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final bool is401 = err.response?.statusCode == 401;
    final String path = err.requestOptions.path;
    final bool isAuthCall = path.startsWith('/api/v1/auth/');
    final bool alreadyRetried =
        err.requestOptions.extra['__retried'] == true;

    if (!is401 || isAuthCall || alreadyRetried) {
      handler.next(err);
      return;
    }

    final bool refreshed = await _refreshOnce();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    // Retry the original request with the fresh token.
    try {
      final String? token = await _tokens.readAccessToken();
      final RequestOptions ro = err.requestOptions;
      ro.extra['__retried'] = true;
      if (token != null && token.isNotEmpty) {
        ro.headers['Authorization'] = 'Bearer $token';
      }
      final Response<dynamic> res = await _dio.fetch<dynamic>(ro);
      handler.resolve(res);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<bool> _refreshOnce() {
    return _refreshing ??=
        _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    try {
      final String? refresh = await _tokens.readRefreshToken();
      if (refresh == null || refresh.isEmpty) return false;

      // A bare Dio (no interceptors) — avoids recursing into ourselves.
      final Dio bare = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        contentType: 'application/json',
      ));
      final Response<dynamic> res = await bare.post<dynamic>(
        '/api/v1/auth/refresh',
        data: <String, dynamic>{'refreshToken': refresh},
      );
      final Object? data = res.data;
      if (data is! Map<String, dynamic>) return false;

      await _tokens.save(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        accessExpiresAt:
            DateTime.parse(data['accessExpiresAt'] as String).toUtc(),
      );
      return true;
    } catch (_) {
      // Refresh token itself is dead — wipe everything, force re-login.
      await _tokens.clear();
      return false;
    }
  }
}
