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

final FutureProvider<List<CustomerSummary>> myCustomersProvider =
    FutureProvider<List<CustomerSummary>>((Ref ref) async {
  if (ref.watch(currentUserProvider)?.role != UserRole.business) {
    return <CustomerSummary>[];
  }
  return ref.read(businessRepositoryProvider).customersForBusiness('me');
});

final FutureProvider<BusinessStats?> myBusinessStatsProvider =
    FutureProvider<BusinessStats?>((Ref ref) async {
  if (ref.watch(currentUserProvider)?.role != UserRole.business) {
    return null;
  }
  return ref.read(businessRepositoryProvider).statsForBusiness('me');
});

/// Rich detail for one customer at the signed-in owner's business.
final FutureProviderFamily<CustomerDetail, String> customerDetailProvider =
    FutureProvider.family<CustomerDetail, String>(
  (Ref ref, String userId) =>
      ref.read(businessRepositoryProvider).customerDetail(userId),
);
