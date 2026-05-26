import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../profile/application/profile_settings_controller.dart';
import '../data/promotions_repository.dart';
import '../domain/promotion.dart';
import '../domain/story.dart';

final Provider<PromotionsRepository> promotionsRepositoryProvider =
    Provider<PromotionsRepository>(
  (Ref ref) => RemotePromotionsRepository(ref.read(apiClientProvider)),
);

final FutureProvider<List<StoryGroup>> storyGroupsProvider =
    FutureProvider<List<StoryGroup>>((Ref ref) {
  ref.watch(languageProvider);
  return ref.read(promotionsRepositoryProvider).fetchStoryGroups();
});

final FutureProvider<List<Promotion>> promotionsProvider =
    FutureProvider<List<Promotion>>((Ref ref) {
  ref.watch(languageProvider);
  return ref.read(promotionsRepositoryProvider).fetchPromotions();
});

/// Tracks which story groups the user has already opened in this session.
final StateProvider<Set<String>> viewedStoryGroupsProvider =
    StateProvider<Set<String>>((Ref ref) => <String>{});
