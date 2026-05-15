import '../../../core/network/api_client.dart';
import '../domain/customer_summary.dart';

abstract class BusinessRepository {
  Future<List<CustomerSummary>> customersForBusiness(String businessId);
  Future<BusinessStats> statsForBusiness(String businessId);
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

/// Backend-backed business repository. Customer list endpoint will be
/// added in a follow-up — for now we return empty until the backend
/// surfaces it (the dashboard shows "no customers yet" gracefully).
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
    // TODO(backend): expose `/api/v1/business/customers` and parse here.
    return const <CustomerSummary>[];
  }
}
