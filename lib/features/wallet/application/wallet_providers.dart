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

final FutureProviderFamily<List<CoinReward>, String> coinRewardsProvider =
    FutureProvider.family<List<CoinReward>, String>(
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
