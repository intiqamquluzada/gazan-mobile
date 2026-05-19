import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
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
    } catch (_) {
      return null;
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
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Company> updateCompany(String id, Map<String, dynamic> patch) async {
    final Map<String, dynamic> json = await _api.put<Map<String, dynamic>>(
      '/api/v1/companies/$id',
      body: patch,
    );
    return Company.fromJson(json);
  }
}
