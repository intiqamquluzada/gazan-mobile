import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/reward_claim.dart';

class RewardsRepository {
  RewardsRepository(this._api);

  final ApiClient _api;

  /// Customer's vouchers — `status` is 'ACTIVE' / 'USED' or null for both.
  Future<List<AppRewardClaim>> mine({String? status}) async {
    final List<dynamic> raw = await _api.get<List<dynamic>>(
      '/api/v1/rewards/mine',
      query: <String, dynamic>{
        if (status != null) 'status': status,
      },
    );
    return raw
        .cast<Map<String, dynamic>>()
        .map(AppRewardClaim.fromJson)
        .toList(growable: false);
  }

  /// Customer buys a coin reward — coins deduct, ACTIVE voucher created.
  Future<AppRewardClaim> purchase(String coinRewardId) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/rewards/purchase',
      body: <String, dynamic>{'coinRewardId': coinRewardId},
    );
    return AppRewardClaim.fromJson(json);
  }

  /// Cashier scan flow: vouchers the customer can use AT this company.
  Future<List<AppRewardClaim>> activeAtCompany({
    required String customerId,
    required String companyId,
  }) async {
    final List<dynamic> raw = await _api.get<List<dynamic>>(
      '/api/v1/business/rewards/customers/$customerId/active-at/$companyId',
    );
    return raw
        .cast<Map<String, dynamic>>()
        .map(AppRewardClaim.fromJson)
        .toList(growable: false);
  }

  /// Cashier confirms claim — marks USED + notifies the customer.
  Future<AppRewardClaim> use({
    required String kind, // COIN | CARD
    required String id,
    required String customerId,
  }) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/business/rewards/use',
      body: <String, dynamic>{
        'kind': kind,
        'id': id,
        'customerId': customerId,
      },
    );
    return AppRewardClaim.fromJson(json);
  }
}

final Provider<RewardsRepository> rewardsRepositoryProvider =
    Provider<RewardsRepository>(
  (Ref ref) => RewardsRepository(ref.read(apiClientProvider)),
);
