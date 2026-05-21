import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/rewards_repository.dart';
import '../domain/reward_claim.dart';

/// Currently selected tab on the "Hədiyyələrim" screen.
final StateProvider<String> rewardsStatusFilterProvider =
    StateProvider<String>((Ref ref) => 'ACTIVE');

final FutureProvider<List<AppRewardClaim>> myActiveRewardsProvider =
    FutureProvider<List<AppRewardClaim>>((Ref ref) async {
  if (ref.watch(currentUserProvider) == null) return <AppRewardClaim>[];
  return ref.read(rewardsRepositoryProvider).mine(status: 'ACTIVE');
});

final FutureProvider<List<AppRewardClaim>> myUsedRewardsProvider =
    FutureProvider<List<AppRewardClaim>>((Ref ref) async {
  if (ref.watch(currentUserProvider) == null) return <AppRewardClaim>[];
  return ref.read(rewardsRepositoryProvider).mine(status: 'USED');
});

/// Business scan flow — vouchers usable at this company for one customer.
final FutureProviderFamily<List<AppRewardClaim>, ({String customerId, String companyId})>
    activeRewardsAtCompanyProvider =
    FutureProvider.family<List<AppRewardClaim>, ({String customerId, String companyId})>(
  (Ref ref, ({String customerId, String companyId}) k) =>
      ref.read(rewardsRepositoryProvider).activeAtCompany(
            customerId: k.customerId,
            companyId: k.companyId,
          ),
);
