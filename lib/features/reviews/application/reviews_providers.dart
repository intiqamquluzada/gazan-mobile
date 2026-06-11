import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reviews_repository.dart';
import '../domain/review.dart';

final FutureProviderFamily<CompanyReviews, String> companyReviewsProvider =
    FutureProvider.family<CompanyReviews, String>((Ref ref, String companyId) {
  return ref.read(reviewsRepositoryProvider).fetch(companyId);
});
