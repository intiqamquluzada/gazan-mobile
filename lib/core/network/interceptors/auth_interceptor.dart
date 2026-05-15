import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

/// Attaches the current access token to every outgoing request.
///
/// On 401 responses we don't transparently retry here — the auth
/// controller handles re-authentication at a higher level so the user
/// can be bounced back to the login screen if the refresh fails too.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens);

  final TokenStorage _tokens;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers['Authorization'] == null) {
      final String? token = await _tokens.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
