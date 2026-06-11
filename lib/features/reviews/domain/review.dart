/// A single customer review of a business.
class Review {
  const Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.createdAt,
    required this.mine,
    this.comment,
  });

  final String id;
  final String userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final bool mine;

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: j['id'] as String,
        userName: (j['userName'] as String?) ?? '',
        rating: (j['rating'] as num?)?.toInt() ?? 0,
        comment: j['comment'] as String?,
        createdAt:
            DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
        mine: (j['mine'] as bool?) ?? false,
      );
}

/// Aggregate + list for a company's reviews.
class CompanyReviews {
  const CompanyReviews({
    required this.average,
    required this.count,
    required this.reviews,
    this.myReview,
  });

  final double average;
  final int count;
  final Review? myReview;
  final List<Review> reviews;

  factory CompanyReviews.fromJson(Map<String, dynamic> j) => CompanyReviews(
        average: (j['average'] as num?)?.toDouble() ?? 0,
        count: (j['count'] as num?)?.toInt() ?? 0,
        myReview: j['myReview'] == null
            ? null
            : Review.fromJson(j['myReview'] as Map<String, dynamic>),
        reviews: ((j['reviews'] as List<dynamic>?) ?? <dynamic>[])
            .map((dynamic e) => Review.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
