import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/panel_models.dart';

/// Cashier window, manual fallback, staff, analytics and owner submissions.
class PanelRepository {
  PanelRepository(this._api);

  final ApiClient _api;

  Future<List<SpendSession>> openSpendSessions() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/business/spend-sessions');
    return raw
        .cast<Map<String, dynamic>>()
        .map(SpendSession.fromJson)
        .toList(growable: false);
  }

  Future<SpendSession> useReward(
    String sessionId, {
    required String kind,
    required String rewardId,
  }) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/business/spend-sessions/$sessionId/use',
      body: <String, dynamic>{'kind': kind, 'id': rewardId},
    );
    return SpendSession.fromJson(json);
  }

  Future<void> closeSession(String sessionId) => _api
      .post<dynamic>('/api/v1/business/spend-sessions/$sessionId/close');

  /// Returns null when no customer has that number.
  Future<CustomerLookup?> lookup(String phone) async {
    try {
      final Map<String, dynamic> json = await _api.get<Map<String, dynamic>>(
        '/api/v1/business/customers/lookup',
        query: <String, dynamic>{'phone': phone},
      );
      return CustomerLookup.fromJson(json);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  Future<void> addStamp({
    required String customerId,
    required String programId,
    int stamps = 1,
  }) =>
      _api.post<dynamic>(
        '/api/v1/scans',
        body: <String, dynamic>{
          'customerId': customerId,
          'programId': programId,
          'stamps': stamps,
          'note': 'Manual',
        },
      );

  Future<void> grantCoins({
    required String customerId,
    required String companyId,
    required int amount,
  }) =>
      _api.post<dynamic>(
        '/api/v1/coins/grant',
        body: <String, dynamic>{
          'customerId': customerId,
          'companyId': companyId,
          'amount': amount,
          'note': 'Manual',
        },
      );

  Future<List<StaffMember>> staff() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/business/staff');
    return raw
        .cast<Map<String, dynamic>>()
        .map(StaffMember.fromJson)
        .toList(growable: false);
  }

  Future<void> addStaff({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) =>
      _api.post<dynamic>(
        '/api/v1/business/staff',
        body: <String, dynamic>{
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

  Future<void> removeStaff(String id) =>
      _api.delete('/api/v1/business/staff/$id');

  Future<BusinessAnalytics> analytics(int days) async {
    final Map<String, dynamic> json = await _api.get<Map<String, dynamic>>(
      '/api/v1/business/analytics',
      query: <String, dynamic>{'days': days},
    );
    return BusinessAnalytics.fromJson(json);
  }

  Future<void> submitNotification({
    required String title,
    required String body,
  }) =>
      _api.post<dynamic>(
        '/api/v1/notifications/submit',
        body: <String, dynamic>{'title': title, 'body': body},
      );

  Future<List<SubmittedNotification>> mySubmissions() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/notifications/submitted');
    return raw
        .cast<Map<String, dynamic>>()
        .map(SubmittedNotification.fromJson)
        .toList(growable: false);
  }
}
