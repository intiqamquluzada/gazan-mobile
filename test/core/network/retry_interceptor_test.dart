import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazan/core/network/interceptors/retry_interceptor.dart';

/// Fails the first [failures] requests with [error], then answers 200.
class _FlakyAdapter implements HttpClientAdapter {
  _FlakyAdapter(this.failures, this.error);

  int failures;
  final Object error;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    calls++;
    if (failures > 0) {
      failures--;
      throw error;
    }
    return ResponseBody.fromString('{"ok":true}', 200,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>['application/json'],
        });
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_FlakyAdapter a) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = a;
  dio.interceptors.add(RetryInterceptor(dio));
  return dio;
}

void main() {
  const HttpException closed =
      HttpException('Connection closed before full header was received');

  test('a GET on a dropped keep-alive connection is retried', () async {
    final _FlakyAdapter a = _FlakyAdapter(1, closed);
    final Response<dynamic> res = await _dio(a).get<dynamic>('/x');
    expect(res.statusCode, 200);
    expect(a.calls, 2);
  });

  test('gives up after two retries', () async {
    final _FlakyAdapter a = _FlakyAdapter(5, closed);
    await expectLater(_dio(a).get<dynamic>('/x'), throwsA(isA<DioException>()));
    expect(a.calls, 3);
  });

  test('a POST that may have reached the server is not repeated', () async {
    final _FlakyAdapter a = _FlakyAdapter(1, closed);
    await expectLater(_dio(a).post<dynamic>('/x', data: <String, int>{'a': 1}),
        throwsA(isA<DioException>()));
    expect(a.calls, 1);
  });

  test('a POST that could not connect at all is retried', () async {
    final _FlakyAdapter a = _FlakyAdapter(1,
        const SocketException('Connection refused', osError: OSError('', 111)));
    final Response<dynamic> res =
        await _dio(a).post<dynamic>('/x', data: <String, int>{'a': 1});
    expect(res.statusCode, 200);
    expect(a.calls, 2);
  });
}
