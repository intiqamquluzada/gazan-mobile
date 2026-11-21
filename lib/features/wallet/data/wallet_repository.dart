import '../../../core/network/api_client.dart';
import '../domain/coin_reward.dart';
import '../domain/coin_summary.dart';

abstract class WalletRepository {
  Future<CoinSummary> fetchSummary();
  Future<CoinSummary> spend({
    required int amount,
    String? companyId,
    String? note,
  });

  /// Reward catalog a customer can claim with coins at one business.
  Future<List<CoinReward>> rewardsForCompany(String companyId);

  /// Platform-wide active reward catalog for the wallet "Hədiyyələrim".
  Future<List<CoinRewardCatalogItem>> rewardsCatalog();

  /// Owner adds a coin reward to their business.
  Future<CoinReward> createReward({
    required String companyId,
    required String title,
    String? description,
    required int coinCost,
  });

  /// Owner changes a coin reward; [active] false takes it off sale while
  /// keeping vouchers already bought.
  Future<CoinReward> updateReward(
    String rewardId, {
    String? title,
    String? description,
    int? coinCost,
    bool? active,
  });

  /// Owner removes a coin reward.
  Future<void> deleteReward(String rewardId);

  /// Cashier confirms a customer claiming a reward (after scanning QR).
  Future<Map<String, dynamic>> redeemReward({
    required String customerId,
    required String rewardId,
  });
}

/// Backend-backed implementation — maps to `CoinController` /
/// `CoinRewardController`.
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
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/coins/me/spend',
      body: <String, dynamic>{
        'amount': amount,
        if (companyId != null) 'companyId': companyId,
        if (note != null) 'note': note,
      },
    );
    return CoinSummary.fromJson(json);
  }

  @override
  Future<List<CoinReward>> rewardsForCompany(String companyId) async {
    // activeOnly=false: the venue's owner also gets paused items (so they
    // can switch them back on); the server returns active items only to
    // everyone else, and customer screens filter on `active` as well.
    final List<dynamic> raw = await _api.get<List<dynamic>>(
      '/api/v1/companies/$companyId/coin-rewards?activeOnly=false',
    );
    return raw
        .cast<Map<String, dynamic>>()
        .map(CoinReward.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<CoinRewardCatalogItem>> rewardsCatalog() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/coin-rewards');
    return raw
        .cast<Map<String, dynamic>>()
        .map(CoinRewardCatalogItem.fromJson)
        .toList(growable: false);
  }

  @override
  Future<CoinReward> createReward({
    required String companyId,
    required String title,
    String? description,
    required int coinCost,
  }) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/companies/$companyId/coin-rewards',
      body: <String, dynamic>{
        'title': title,
        if (description != null) 'description': description,
        'coinCost': coinCost,
      },
    );
    return CoinReward.fromJson(json);
  }

  @override
  Future<CoinReward> updateReward(
    String rewardId, {
    String? title,
    String? description,
    int? coinCost,
    bool? active,
  }) async {
    final Map<String, dynamic> json = await _api.put<Map<String, dynamic>>(
      '/api/v1/coin-rewards/$rewardId',
      body: <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (coinCost != null) 'coinCost': coinCost,
        if (active != null) 'active': active,
      },
    );
    return CoinReward.fromJson(json);
  }

  @override
  Future<void> deleteReward(String rewardId) async {
    await _api.delete('/api/v1/coin-rewards/$rewardId');
  }

  @override
  Future<Map<String, dynamic>> redeemReward({
    required String customerId,
    required String rewardId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/api/v1/coins/redeem-reward',
      body: <String, dynamic>{
        'customerId': customerId,
        'rewardId': rewardId,
      },
    );
  }
}
