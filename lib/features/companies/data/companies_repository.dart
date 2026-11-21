import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/business_category.dart';
import '../domain/company.dart';

abstract class CompaniesRepository {
  Future<List<Company>> fetchAll({BusinessCategory? category, String? query});
  Future<Company?> fetchById(String id);
  Future<List<Company>> fetchFeatured();

  /// Returns the company owned by the signed-in business user.
  Future<Company?> fetchMyCompany();

  /// Owner updates their company profile. Only non-null fields change.
  Future<Company> updateCompany(String id, Map<String, dynamic> patch);

  /// Owner creates their business (one per owner).
  Future<Company> createCompany(Map<String, dynamic> body);
}

/// Backend-backed implementation. Each method maps directly to one
/// {@link CompanyController} endpoint.
class RemoteCompaniesRepository implements CompaniesRepository {
  RemoteCompaniesRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Company>> fetchAll({
    BusinessCategory? category,
    String? query,
  }) async {
    final List<dynamic> raw = await _api.get<List<dynamic>>(
      '/api/v1/companies',
      query: <String, dynamic>{
        if (category != null) 'category': category.wire,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );
    return raw
        .cast<Map<String, dynamic>>()
        .map(Company.fromJson)
        .toList(growable: false);
  }

  @override
  Future<Company?> fetchById(String id) async {
    try {
      final Map<String, dynamic> json =
          await _api.get<Map<String, dynamic>>('/api/v1/companies/$id');
      return Company.fromJson(json);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  @override
  Future<List<Company>> fetchFeatured() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/companies/featured');
    return raw
        .cast<Map<String, dynamic>>()
        .map(Company.fromJson)
        .toList(growable: false);
  }

  @override
  Future<Company?> fetchMyCompany() async {
    try {
      final Map<String, dynamic> json =
          await _api.get<Map<String, dynamic>>('/api/v1/companies/me');
      return Company.fromJson(json);
    } on ApiException catch (e) {
      // Only "you have no business yet" means null; a network failure must
      // not look like it and offer an owner the create-business form.
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  /// Image references are saved host-independent.
  Map<String, dynamic> _withStoredMedia(Map<String, dynamic> body) {
    final Map<String, dynamic> out = Map<String, dynamic>.of(body);
    final Object? logo = out['logoUrl'];
    if (logo is String) out['logoUrl'] = AppConfig.storedMediaUrl(logo);
    final Object? photos = out['photoUrls'];
    if (photos is String) {
      out['photoUrls'] =
          photos.split('\n').map(AppConfig.storedMediaUrl).join('\n');
    }
    return out;
  }

  @override
  Future<Company> updateCompany(String id, Map<String, dynamic> patch) async {
    final Map<String, dynamic> json = await _api.put<Map<String, dynamic>>(
      '/api/v1/companies/$id',
      body: _withStoredMedia(patch),
    );
    return Company.fromJson(json);
  }

  @override
  Future<Company> createCompany(Map<String, dynamic> body) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/companies',
      body: _withStoredMedia(body),
    );
    return Company.fromJson(json);
  }
}
