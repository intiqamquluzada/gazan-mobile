import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// One dish/product line on a business's structured menu.
class MenuItem {
  const MenuItem({
    required this.id,
    required this.category,
    required this.name,
    this.description,
    this.price,
    this.sortOrder = 0,
  });

  final String id;
  final String category;
  final String name;
  final String? description;
  final double? price;
  final int sortOrder;

  factory MenuItem.fromJson(Map<String, dynamic> j) {
    return MenuItem(
      id: j['id'] as String,
      category: (j['category'] as String?) ?? 'Digər',
      name: (j['name'] as String?) ?? '',
      description: j['description'] as String?,
      price: (j['price'] as num?)?.toDouble(),
      sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class MenuRepository {
  MenuRepository(this._api);

  final ApiClient _api;

  /// Public — the structured menu for a company (customer + admin use it).
  Future<List<MenuItem>> forCompany(String companyId) async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/companies/$companyId/menu');
    return raw
        .cast<Map<String, dynamic>>()
        .map(MenuItem.fromJson)
        .toList(growable: false);
  }

  // ── Admin ──
  Future<void> add({
    required String companyId,
    required String category,
    required String name,
    String? description,
    double? price,
    int sortOrder = 0,
  }) async {
    await _api.post<dynamic>(
      '/api/v1/admin/companies/$companyId/menu',
      body: <String, dynamic>{
        'category': category,
        'name': name,
        'description': description,
        'price': price,
        'sortOrder': sortOrder,
      },
    );
  }

  Future<void> delete(String itemId) async {
    await _api.delete('/api/v1/admin/menu/$itemId');
  }
}

final Provider<MenuRepository> menuRepositoryProvider =
    Provider<MenuRepository>(
  (Ref ref) => MenuRepository(ref.read(apiClientProvider)),
);

/// The structured menu for a company, grouped later by the UI.
final FutureProviderFamily<List<MenuItem>, String> companyMenuProvider =
    FutureProvider.family<List<MenuItem>, String>(
  (Ref ref, String companyId) =>
      ref.read(menuRepositoryProvider).forCompany(companyId),
);
