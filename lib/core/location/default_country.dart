import 'dart:ui' show PlatformDispatcher;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Best-effort default country (ISO code, e.g. "AZ") for the phone-number
/// country-code picker. Resolution order:
///   1. IP geolocation (ip-api.com) — matches where the user actually is.
///   2. The device's region setting.
///   3. Azerbaijan as the final fallback.
///
/// Never throws — any failure just falls through to the next source.
final FutureProvider<String> defaultCountryCodeProvider =
    FutureProvider<String>((Ref ref) async {
  // 1) IP-based lookup.
  try {
    final Dio dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
    ));
    final Response<dynamic> res = await dio.get<dynamic>(
      'http://ip-api.com/json/?fields=countryCode',
    );
    final Object? data = res.data;
    if (data is Map && data['countryCode'] is String) {
      final String cc = (data['countryCode'] as String).toUpperCase();
      if (cc.length == 2) return cc;
    }
  } catch (_) {
    // fall through
  }

  // 2) Device region.
  final String? region =
      PlatformDispatcher.instance.locale.countryCode;
  if (region != null && region.length == 2) {
    return region.toUpperCase();
  }

  // 3) Fallback.
  return 'AZ';
});
