import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/review.dart';

class ReviewsRepository {
  ReviewsRepository(this._api);

  final ApiClient _api;

  Future<CompanyReviews> fetch(String companyId) async {
    final Map<String, dynamic> json = await _api.get<Map<String, dynamic>>(
      '/api/v1/companies/$companyId/reviews',
    );
    return CompanyReviews.fromJson(json);
  }

  Future<void> submit({
    required String companyId,
    required int rating,
    String? comment,
  }) async {
    await _api.post<dynamic>(
      '/api/v1/companies/$companyId/reviews',
      body: <String, dynamic>{'rating': rating, 'comment': comment},
    );
  }
}

final Provider<ReviewsRepository> reviewsRepositoryProvider =
    Provider<ReviewsRepository>(
  (Ref ref) => ReviewsRepository(ref.read(apiClientProvider)),
);
