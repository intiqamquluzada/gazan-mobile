import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../storage/token_storage.dart';

enum _RefreshOutcome { refreshed, dead, transient }

/// `RequestOptions.extra` flag: never refresh tokens for this request.
const String kNoRefresh = 'noRefresh';

/// Transparently refreshes an expired access token.
///
/// When any non-auth request comes back `401`, this interceptor calls
/// `/api/v1/auth/refresh`, stores the new pair and retries once.
///
/// Concurrency-safe: parallel 401s share one refresh call.
///
/// The session only ends when the server actually rejects the refresh
/// token. A timeout, a DNS failure or a 5xx leaves the tokens in place, so
/// a bad network moment can never log the user out.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor(this._dio, this._tokens, {this.onSessionExpired});

  final Dio _dio;
  final TokenStorage _tokens;

  /// Called once the refresh token is confirmed dead.
  final void Function()? onSessionExpired;

  Future<_RefreshOutcome>? _refreshing;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final bool is401 = err.response?.statusCode == 401;
    final String path = err.requestOptions.path;
    final bool isAuthCall = path.startsWith('/api/v1/auth/');
    final bool alreadyRetried = err.requestOptions.extra['__retried'] == true;
    // Background clean-up after sign-out carries the old session's token;
    // refreshing (or ending "the" session) there could hit the next account.
    final bool noRefresh = err.requestOptions.extra[kNoRefresh] == true;

    if (!is401 || isAuthCall || alreadyRetried || noRefresh) {
      handler.next(err);
      return;
    }

    final _RefreshOutcome outcome = await _refreshOnce();
    if (!kReleaseMode) debugPrint('[net] token refresh: $outcome');
    if (outcome != _RefreshOutcome.refreshed) {
      handler.next(err);
      return;
    }

    try {
      final String? token = await _tokens.readAccessToken();
      final RequestOptions ro = err.requestOptions;
      ro.extra['__retried'] = true;
      if (token != null && token.isNotEmpty) {
        ro.headers['Authorization'] = 'Bearer $token';
      }
      // A FormData body is single-use; an upload needs a fresh copy.
      final Object? body = ro.data;
      if (body is FormData) ro.data = body.clone();
      final Response<dynamic> res = await _dio.fetch<dynamic>(ro);
      handler.resolve(res);
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<_RefreshOutcome> _refreshOnce() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<_RefreshOutcome> _doRefresh() async {
    final String? refresh = await _tokens.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return _end();

    try {
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
      if (data is! Map<String, dynamic>) return _RefreshOutcome.transient;

      await _tokens.save(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        accessExpiresAt:
            DateTime.parse(data['accessExpiresAt'] as String).toUtc(),
      );
      return _RefreshOutcome.refreshed;
    } on DioException catch (e) {
      final int code = e.response?.statusCode ?? 0;
      if (code == 400 || code == 401 || code == 403) return _end();
      return _RefreshOutcome.transient;
    } catch (_) {
      return _RefreshOutcome.transient;
    }
  }

  Future<_RefreshOutcome> _end() async {
    await _tokens.clear();
    onSessionExpired?.call();
    return _RefreshOutcome.dead;
  }
}
