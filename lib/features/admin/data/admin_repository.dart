import '../../../core/network/api_client.dart';
import '../domain/admin_models.dart';

/// Backend-backed admin panel data source. All endpoints require an
/// ADMIN-role JWT (enforced server-side via `@PreAuthorize`).
class AdminRepository {
  AdminRepository(this._api);

  final ApiClient _api;

  Future<AdminStats> stats() async {
    final Map<String, dynamic> json =
        await _api.get<Map<String, dynamic>>('/api/v1/admin/stats');
    return AdminStats.fromJson(json);
  }

  Future<AdminPage<AdminUser>> users({
    String? q,
    String? role,
    int page = 0,
    int size = 20,
  }) async {
    final Map<String, dynamic> json =
        await _api.get<Map<String, dynamic>>(
      '/api/v1/admin/users',
      query: <String, dynamic>{
        if (q != null && q.isNotEmpty) 'q': q,
        if (role != null) 'role': role,
        'page': page,
        'size': size,
      },
    );
    return AdminPage<AdminUser>.fromJson(json, AdminUser.fromJson);
  }

  Future<AdminUser> setUserRole(String userId, String role) async {
    final Map<String, dynamic> json = await _api.patch<Map<String, dynamic>>(
      '/api/v1/admin/users/$userId/role',
      body: <String, dynamic>{'role': role},
    );
    return AdminUser.fromJson(json);
  }

  Future<AdminUser> setUserActive(String userId, bool active) async {
    final Map<String, dynamic> json = await _api.patch<Map<String, dynamic>>(
      '/api/v1/admin/users/$userId/status',
      body: <String, dynamic>{'active': active},
    );
    return AdminUser.fromJson(json);
  }

  Future<AdminPage<AdminCompany>> companies({
    String? q,
    int page = 0,
    int size = 20,
  }) async {
    final Map<String, dynamic> json =
        await _api.get<Map<String, dynamic>>(
      '/api/v1/admin/companies',
      query: <String, dynamic>{
        if (q != null && q.isNotEmpty) 'q': q,
        'page': page,
        'size': size,
      },
    );
    return AdminPage<AdminCompany>.fromJson(json, AdminCompany.fromJson);
  }

  Future<AdminCompany> setCompanyFeatured(
      String companyId, bool featured) async {
    final Map<String, dynamic> json = await _api.patch<Map<String, dynamic>>(
      '/api/v1/admin/companies/$companyId/featured',
      body: <String, dynamic>{'featured': featured},
    );
    return AdminCompany.fromJson(json);
  }

  Future<AdminPage<AdminCoinTxn>> coinTransactions({
    int page = 0,
    int size = 30,
  }) async {
    final Map<String, dynamic> json =
        await _api.get<Map<String, dynamic>>(
      '/api/v1/admin/coins/transactions',
      query: <String, dynamic>{'page': page, 'size': size},
    );
    return AdminPage<AdminCoinTxn>.fromJson(json, AdminCoinTxn.fromJson);
  }

  Future<CoinSummary> coinSummary() async {
    final Map<String, dynamic> json =
        await _api.get<Map<String, dynamic>>('/api/v1/admin/coins/summary');
    return CoinSummary.fromJson(json);
  }

  Future<AdminCoinTxn> adjustCoins({
    required String userId,
    String? companyId,
    required int amount,
    String? note,
  }) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/admin/coins/adjust',
      body: <String, dynamic>{
        'userId': userId,
        if (companyId != null) 'companyId': companyId,
        'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return AdminCoinTxn.fromJson(json);
  }
}
