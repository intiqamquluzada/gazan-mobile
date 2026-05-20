import '../../../core/network/api_client.dart';
import '../domain/customer_summary.dart';

abstract class BusinessRepository {
  Future<List<CustomerSummary>> customersForBusiness(String businessId);
  Future<BusinessStats> statsForBusiness(String businessId);

  /// Owner credits coins to a customer after scanning their QR.
  Future<void> grantCoins({
    required String customerId,
    String? companyId,
    required int amount,
    String? note,
  });
}

class BusinessStats {
  const BusinessStats({
    required this.activeCustomers,
    required this.stampsToday,
    required this.rewardsThisWeek,
    required this.repeatRate,
  });

  final int activeCustomers;
  final int stampsToday;
  final int rewardsThisWeek;
  final double repeatRate;

  factory BusinessStats.fromJson(Map<String, dynamic> json) {
    return BusinessStats(
      activeCustomers: ((json['activeCustomers'] as num?) ?? 0).toInt(),
      stampsToday: ((json['stampsToday'] as num?) ?? 0).toInt(),
      rewardsThisWeek: ((json['rewardsThisWeek'] as num?) ?? 0).toInt(),
      repeatRate: ((json['repeatRate'] as num?) ?? 0).toDouble(),
    );
  }
}

/// Backend-backed business repository.
class RemoteBusinessRepository implements BusinessRepository {
  RemoteBusinessRepository(this._api);

  final ApiClient _api;

  @override
  Future<BusinessStats> statsForBusiness(String businessId) async {
    final Map<String, dynamic> json =
        await _api.get<Map<String, dynamic>>('/api/v1/business/stats');
    return BusinessStats.fromJson(json);
  }

  @override
  Future<List<CustomerSummary>> customersForBusiness(String businessId) async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/business/customers');
    return raw
        .cast<Map<String, dynamic>>()
        .map(CustomerSummary.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> grantCoins({
    required String customerId,
    String? companyId,
    required int amount,
    String? note,
  }) async {
    await _api.post<dynamic>(
      '/api/v1/coins/grant',
      body: <String, dynamic>{
        'customerId': customerId,
        if (companyId != null) 'companyId': companyId,
        'amount': amount,
        if (note != null) 'note': note,
      },
    );
  }
}
