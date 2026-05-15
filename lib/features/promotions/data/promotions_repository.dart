import '../../../core/network/api_client.dart';
import '../domain/promotion.dart';
import '../domain/story.dart';

/// Stories + promo banners shown on the discover feed.
abstract class PromotionsRepository {
  Future<List<StoryGroup>> fetchStoryGroups();
  Future<List<Story>> fetchStoriesForCompany(String companyId);
  Future<List<Promotion>> fetchPromotions();
}

class RemotePromotionsRepository implements PromotionsRepository {
  RemotePromotionsRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<StoryGroup>> fetchStoryGroups() async {
    final List<dynamic> raw = await _api.get<List<dynamic>>('/api/v1/stories');
    return raw
        .cast<Map<String, dynamic>>()
        .map(StoryGroup.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<Story>> fetchStoriesForCompany(String companyId) async {
    final List<dynamic> raw = await _api.get<List<dynamic>>(
      '/api/v1/companies/$companyId/stories',
    );
    return raw
        .cast<Map<String, dynamic>>()
        .map(Story.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<Promotion>> fetchPromotions() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/promotions');
    return raw
        .cast<Map<String, dynamic>>()
        .map(Promotion.fromJson)
        .toList(growable: false);
  }
}
