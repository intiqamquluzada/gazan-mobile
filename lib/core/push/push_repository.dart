import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

/// Talks to the backend's `/push/tokens` endpoints. Pure HTTP — works with
/// or without Firebase; [PushService] only calls it once it has a token.
class PushRepository {
  PushRepository(this._api);

  final ApiClient _api;

  Future<void> register(String token, String platform) async {
    await _api.post<dynamic>(
      '/api/v1/push/tokens',
      body: <String, dynamic>{'token': token, 'platform': platform},
    );
  }

  Future<void> unregister(String token) async {
    await _api.delete(
      '/api/v1/push/tokens',
      body: <String, dynamic>{'token': token},
    );
  }
}

final Provider<PushRepository> pushRepositoryProvider = Provider<PushRepository>(
  (Ref ref) => PushRepository(ref.read(apiClientProvider)),
);
