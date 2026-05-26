import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../profile/application/profile_settings_controller.dart';
import '../data/companies_repository.dart';
import '../domain/business_category.dart';
import '../domain/company.dart';

final Provider<CompaniesRepository> companiesRepositoryProvider =
    Provider<CompaniesRepository>(
  (Ref ref) => RemoteCompaniesRepository(ref.read(apiClientProvider)),
);

/// Currently selected category filter on the discover feed.
final StateProvider<BusinessCategory?> selectedCategoryProvider =
    StateProvider<BusinessCategory?>((Ref ref) => null);

/// Search query on the discover feed.
final StateProvider<String> searchQueryProvider =
    StateProvider<String>((Ref ref) => '');

final FutureProvider<List<Company>> companiesProvider =
    FutureProvider<List<Company>>((Ref ref) {
  // Re-fetch when the UI language changes so the backend can return
  // category labels and any localized fields in the new language.
  ref.watch(languageProvider);
  final BusinessCategory? category = ref.watch(selectedCategoryProvider);
  final String query = ref.watch(searchQueryProvider);
  return ref
      .read(companiesRepositoryProvider)
      .fetchAll(category: category, query: query);
});

final FutureProvider<List<Company>> featuredCompaniesProvider =
    FutureProvider<List<Company>>((Ref ref) {
  ref.watch(languageProvider);
  return ref.read(companiesRepositoryProvider).fetchFeatured();
});

final FutureProviderFamily<Company?, String> companyByIdProvider =
    FutureProvider.family<Company?, String>((Ref ref, String id) {
  ref.watch(languageProvider);
  return ref.read(companiesRepositoryProvider).fetchById(id);
});

/// The company owned by the signed-in business user. Null if customer.
final FutureProvider<Company?> myCompanyProvider =
    FutureProvider<Company?>((Ref ref) {
  ref.watch(languageProvider);
  return ref.read(companiesRepositoryProvider).fetchMyCompany();
});
