import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazan/core/network/api_client.dart';
import 'package:qazan/core/network/api_exception.dart';

/// Answers every request with the exact 401 production sent before the
/// server fix: Azerbaijani text encoded as ISO-8859-1.
class _Latin1Unauthorized implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final List<int> bytes = latin1.encode(
        '{"code":"UNAUTHORIZED","message":"Davam etm? üçün hesab?na daxil ol.","status":401}');
    return ResponseBody.fromBytes(bytes, 401,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>['application/json;charset=ISO-8859-1'],
        });
  }

  @override
  void close({bool force = false}) {}
}

Future<ApiException> _errorFrom(Dio dio) async {
  try {
    await ApiClient(dio).get<dynamic>('/api/v1/users/me');
  } on ApiException catch (e) {
    return e;
  }
  throw StateError('expected an error');
}

Dio _dio({ResponseDecoder? decoder}) => Dio(BaseOptions(
      baseUrl: 'https://example.test',
      responseType: ResponseType.json,
      responseDecoder: decoder,
    ))
      ..httpClientAdapter = _Latin1Unauthorized();

void main() {
  test('without the lenient decoder the 401 looked like "no internet"',
      () async {
    final ApiException e = await _errorFrom(_dio());
    expect(e.isNetwork, isTrue); // the bug, kept as a reminder
  });

  test('with it the app sees the 401, so the token refresh can run',
      () async {
    final ApiException e = await _errorFrom(_dio(decoder: lenientUtf8Decoder));
    expect(e.isNetwork, isFalse);
    expect(e.status, 401);
    expect(e.code, 'UNAUTHORIZED');
  });
}
