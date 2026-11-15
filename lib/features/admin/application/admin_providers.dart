import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user_role.dart';
import '../data/admin_repository.dart';
import '../domain/admin_models.dart';

final Provider<AdminRepository> adminRepositoryProvider =
    Provider<AdminRepository>(
  (Ref ref) => AdminRepository(ref.read(apiClientProvider)),
);

/// Platform dashboard snapshot. Returns null for non-admins so the
/// provider is safe to watch even before role is known.
final FutureProvider<AdminStats?> adminStatsProvider =
    FutureProvider<AdminStats?>((Ref ref) async {
  if (ref.watch(currentUserProvider)?.role != UserRole.admin) return null;
  return ref.read(adminRepositoryProvider).stats();
});

final AutoDisposeFutureProviderFamily<AdminCompanyDetail, String>
    adminCompanyDetailProvider =
    FutureProvider.autoDispose.family<AdminCompanyDetail, String>(
  (Ref ref, String id) => ref.read(adminRepositoryProvider).companyDetail(id),
);

final AutoDisposeFutureProviderFamily<AdminUserDetail, String>
    adminUserDetailProvider =
    FutureProvider.autoDispose.family<AdminUserDetail, String>(
  (Ref ref, String id) => ref.read(adminRepositoryProvider).userDetail(id),
);

final AutoDisposeFutureProvider<List<CompanyCoinRow>> adminCoinsByCompanyProvider =
    FutureProvider.autoDispose<List<CompanyCoinRow>>(
  (Ref ref) => ref.read(adminRepositoryProvider).coinsByCompany(),
);

final FutureProvider<CoinSummary?> adminCoinSummaryProvider =
    FutureProvider<CoinSummary?>((Ref ref) async {
  if (ref.watch(currentUserProvider)?.role != UserRole.admin) return null;
  return ref.read(adminRepositoryProvider).coinSummary();
});

/// Every venue on the platform, whatever its status — for admin pickers
/// (coin adjustment, NFC cards, promotions). The public companies list only
/// shows approved venues, which is why pickers must not use it.
final AutoDisposeFutureProvider<List<AdminCompany>> adminCompanyOptionsProvider =
    FutureProvider.autoDispose<List<AdminCompany>>((Ref ref) async {
  final AdminRepository repo = ref.read(adminRepositoryProvider);
  final List<AdminCompany> all = <AdminCompany>[];
  // The server caps a page at 100; stop after 10 pages as a safety net.
  for (int page = 0; page < 10; page++) {
    final AdminPage<AdminCompany> p =
        await repo.companies(page: page, size: 100);
    all.addAll(p.content);
    if (page + 1 >= p.totalPages) break;
  }
  all.sort((AdminCompany a, AdminCompany b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return all;
});
