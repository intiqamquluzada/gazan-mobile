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
