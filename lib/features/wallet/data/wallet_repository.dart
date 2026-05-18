import '../../../core/network/api_client.dart';
import '../domain/coin_summary.dart';

abstract class WalletRepository {
  Future<CoinSummary> fetchSummary();
  Future<CoinSummary> spend({
    required int amount,
    String? companyId,
    String? note,
  });
}

/// Backend-backed implementation — maps to `CoinController`.
class RemoteWalletRepository implements WalletRepository {
  RemoteWalletRepository(this._api);

  final ApiClient _api;

  @override
  Future<CoinSummary> fetchSummary() async {
    final Map<String, dynamic> json =
        await _api.get<Map<String, dynamic>>('/api/v1/coins/me');
    return CoinSummary.fromJson(json);
  }

  @override
  Future<CoinSummary> spend({
    required int amount,
    String? companyId,
    String? note,
  }) async {
    final Map<String, dynamic> json =
        await _api.post<Map<String, dynamic>>(
      '/api/v1/coins/me/spend',
      body: <String, dynamic>{
        'amount': amount,
        if (companyId != null) 'companyId': companyId,
        if (note != null) 'note': note,
      },
    );
    return CoinSummary.fromJson(json);
  }
}
