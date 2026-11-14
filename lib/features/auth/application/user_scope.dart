import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin/application/admin_providers.dart';
import '../../business/application/business_providers.dart';
import '../../business/application/panel_providers.dart';
import '../../business/presentation/business_pending_rewards_screen.dart';
import '../../companies/application/companies_providers.dart';
import '../../favorites/application/favorites_providers.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../nfc/data/nfc_admin_repository.dart';
import '../../notifications/application/notifications_providers.dart';
import '../../reviews/application/reviews_providers.dart';
import '../../rewards/application/rewards_providers.dart';
import '../../wallet/application/wallet_providers.dart';

/// Drops every cached value that belongs to one account, so the next person
/// to sign in on this device never sees the previous user's balance,
/// favourites or company.
void resetUserScopedProviders(Ref ref) {
  ref
    ..invalidate(coinSummaryProvider)
    ..invalidate(myCompanyProvider)
    ..invalidate(favoritesProvider)
    ..invalidate(favoriteCompaniesProvider)
    ..invalidate(myCardsProvider)
    ..invalidate(myActiveRewardsProvider)
    ..invalidate(myUsedRewardsProvider)
    ..invalidate(myBusinessStatsProvider)
    ..invalidate(myCustomersProvider)
    ..invalidate(customerDetailProvider)
    ..invalidate(myNfcCardsProvider)
    ..invalidate(myNfcTapsProvider)
    ..invalidate(adminNfcCardsProvider)
    ..invalidate(pendingRewardsProvider)
    ..invalidate(notificationInboxProvider)
    ..invalidate(unreadCountProvider)
    ..invalidate(adminSentProvider)
    ..invalidate(adminStatsProvider)
    ..invalidate(adminCoinSummaryProvider)
    ..invalidate(companyReviewsProvider)
    ..invalidate(businessAnalyticsProvider)
    ..invalidate(staffProvider)
    ..invalidate(mySubmissionsProvider);
}
