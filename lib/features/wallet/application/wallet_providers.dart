import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../profile/application/profile_settings_controller.dart';
import '../data/wallet_repository.dart';
import '../domain/coin_reward.dart';
import '../domain/coin_summary.dart';

final Provider<WalletRepository> walletRepositoryProvider =
    Provider<WalletRepository>(
  (Ref ref) => RemoteWalletRepository(ref.read(apiClientProvider)),
);

final FutureProvider<CoinSummary> coinSummaryProvider =
    FutureProvider<CoinSummary>((Ref ref) {
  ref.watch(languageProvider);
  return ref.read(walletRepositoryProvider).fetchSummary();
});

// autoDispose: a venue's catalog is fetched again each time its page opens,
// so owners' changes reach customers without restarting the app.
final AutoDisposeFutureProviderFamily<List<CoinReward>, String>
    coinRewardsProvider =
    FutureProvider.autoDispose.family<List<CoinReward>, String>(
        (Ref ref, String companyId) {
  ref.watch(languageProvider);
  return ref.read(walletRepositoryProvider).rewardsForCompany(companyId);
});

/// Platform-wide reward catalog for the wallet "Hədiyyələrim" section.
final FutureProvider<List<CoinRewardCatalogItem>> coinCatalogProvider =
    FutureProvider<List<CoinRewardCatalogItem>>((Ref ref) {
  ref.watch(languageProvider);
  return ref.read(walletRepositoryProvider).rewardsCatalog();
});
