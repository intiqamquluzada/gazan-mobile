import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// Retries a request that died on the way, before any answer came back.
///
/// The usual cause is not a missing network: the phone reuses a keep-alive
/// connection that the server (Apache) or the mobile carrier has already
/// closed, and the request fails at once with "connection closed" or
/// "connection reset". A second try on a fresh connection succeeds, so the
/// user should never see "no internet" for it.
///
/// Reads (GET/HEAD) are retried for any transport failure. Writes are
/// retried only when the request provably never left the phone (could not
/// connect), so a payment or a stamp is never sent twice.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.retries = 2});

  final Dio _dio;
  final int retries;

  static const String _kAttempt = '__retryAttempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions ro = err.requestOptions;
    final int attempt = (ro.extra[_kAttempt] as int?) ?? 0;
    if (attempt >= retries || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(Duration(milliseconds: 300 * (attempt + 1)));
    ro.extra[_kAttempt] = attempt + 1;
    final Object? body = ro.data;
    if (body is FormData) ro.data = body.clone();
    try {
      handler.resolve(await _dio.fetch<dynamic>(ro));
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(err);
    }
  }

  static bool _shouldRetry(DioException e) {
    if (e.type == DioExceptionType.cancel ||
        e.type == DioExceptionType.badCertificate) {
      return false;
    }
    final bool read = const <String>{'GET', 'HEAD'}
        .contains(e.requestOptions.method.toUpperCase());
    final int? status = e.response?.statusCode;
    if (status != null) {
      // The proxy could not reach the backend for a moment (restart,
      // stale pooled connection). Reads are safe to ask again.
      return read && (status == 502 || status == 503 || status == 504);
    }
    if (read) return true;
    // Writes: only when nothing was sent.
    return e.type == DioExceptionType.connectionTimeout ||
        e.error is SocketException &&
            _neverConnected(e.error! as SocketException);
  }

  static bool _neverConnected(SocketException e) {
    final String m = e.message.toLowerCase();
    final int? code = e.osError?.errorCode;
    // ECONNREFUSED (61 iOS / 111 Android), host lookup failures.
    return code == 61 ||
        code == 111 ||
        m.contains('failed host lookup') ||
        m.contains('connection refused');
  }
}
