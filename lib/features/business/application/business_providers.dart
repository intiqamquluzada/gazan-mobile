import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user_role.dart';
import '../data/business_repository.dart';
import '../domain/customer_detail.dart';
import '../domain/customer_summary.dart';

final Provider<BusinessRepository> businessRepositoryProvider =
    Provider<BusinessRepository>(
  (Ref ref) => RemoteBusinessRepository(ref.read(apiClientProvider)),
);

// autoDispose: these reload whenever their screen is opened again, since
// customers keep earning stamps and coins while the owner is elsewhere.
final AutoDisposeFutureProvider<List<CustomerSummary>> myCustomersProvider =
    FutureProvider.autoDispose<List<CustomerSummary>>((Ref ref) async {
  if (ref.watch(currentUserProvider)?.role != UserRole.business) {
    return <CustomerSummary>[];
  }
  return ref.read(businessRepositoryProvider).customersForBusiness('me');
});

final AutoDisposeFutureProvider<BusinessStats?> myBusinessStatsProvider =
    FutureProvider.autoDispose<BusinessStats?>((Ref ref) async {
  if (ref.watch(currentUserProvider)?.role != UserRole.business) {
    return null;
  }
  return ref.read(businessRepositoryProvider).statsForBusiness('me');
});

/// Rich detail for one customer at the signed-in owner's business.
final AutoDisposeFutureProviderFamily<CustomerDetail, String>
    customerDetailProvider =
    FutureProvider.autoDispose.family<CustomerDetail, String>(
  (Ref ref, String userId) =>
      ref.read(businessRepositoryProvider).customerDetail(userId),
);
