import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

/// Attaches the current access token to outgoing requests that need it.
///
/// - Auth endpoints (`/api/v1/auth/...`) are skipped entirely — no token
///   exists when registering / logging in, and trying to read storage
///   has caused hangs on some browsers (Safari + localStorage edge cases).
/// - Token read failures are swallowed — we never want a storage hiccup
///   to block the actual HTTP call.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens);

  final TokenStorage _tokens;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String path = options.path;
    final bool isPublicAuthCall = path.startsWith('/api/v1/auth/');

    if (!isPublicAuthCall && options.headers['Authorization'] == null) {
      try {
        final String? token = await _tokens.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // Storage failure should never block a request — let it go out
        // unauthenticated; the server will respond 401 if it needs auth.
      }
    }
    handler.next(options);
  }
}
