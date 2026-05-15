import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/profile/application/profile_settings_controller.dart';

/// Sends the user's preferred language as `Accept-Language` so the
/// backend localizes error messages and other content.
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String code = _ref.read(languageProvider);
    options.headers['Accept-Language'] = code;
    handler.next(options);
  }
}
