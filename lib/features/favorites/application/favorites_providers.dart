import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../data/favorites_repository.dart';

/// Holds the set of favorited company IDs and toggles them optimistically
/// so the heart flips instantly, reverting if the network call fails.
class FavoritesController extends StateNotifier<Set<String>> {
  FavoritesController(this._repo) : super(<String>{}) {
    _load();
  }

  final FavoritesRepository _repo;

  Future<void> _load() async {
    try {
      state = await _repo.fetchIds();
    } catch (_) {
      // Leave empty — a transient failure shouldn't crash the feed.
    }
  }

  bool isFavorite(String companyId) => state.contains(companyId);

  Future<void> toggle(String companyId) async {
    final bool wasFavorite = state.contains(companyId);
    state = wasFavorite
        ? (state.difference(<String>{companyId}))
        : <String>{...state, companyId};
    try {
      if (wasFavorite) {
        await _repo.remove(companyId);
      } else {
        await _repo.add(companyId);
      }
    } catch (_) {
      // Revert on failure.
      state = wasFavorite
          ? <String>{...state, companyId}
          : (state.difference(<String>{companyId}));
    }
  }
}

final StateNotifierProvider<FavoritesController, Set<String>>
    favoritesProvider = StateNotifierProvider<FavoritesController, Set<String>>(
  (Ref ref) => FavoritesController(ref.read(favoritesRepositoryProvider)),
);

/// The favorited companies, resolved to full objects for the list screen.
final FutureProvider<List<Company>> favoriteCompaniesProvider =
    FutureProvider<List<Company>>((Ref ref) async {
  final Set<String> ids = ref.watch(favoritesProvider);
  if (ids.isEmpty) return <Company>[];
  final List<Company> all =
      await ref.read(companiesRepositoryProvider).fetchAll();
  return all.where((Company c) => ids.contains(c.id)).toList();
});
