import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Wraps the backend `/favorites` endpoints. The server stores only the
/// (user, company) link; resolving to full companies happens client-side.
class FavoritesRepository {
  FavoritesRepository(this._api);

  final ApiClient _api;

  Future<Set<String>> fetchIds() async {
    final List<dynamic> list =
        await _api.get<List<dynamic>>('/api/v1/favorites');
    return list.map((dynamic e) => e as String).toSet();
  }

  Future<void> add(String companyId) async {
    await _api.post<dynamic>('/api/v1/favorites/$companyId');
  }

  Future<void> remove(String companyId) async {
    await _api.delete('/api/v1/favorites/$companyId');
  }
}

final Provider<FavoritesRepository> favoritesRepositoryProvider =
    Provider<FavoritesRepository>(
  (Ref ref) => FavoritesRepository(ref.read(apiClientProvider)),
);
