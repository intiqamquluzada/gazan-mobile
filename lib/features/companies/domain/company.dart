import 'business_category.dart';

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.tagline,
    required this.category,
    required this.logoEmoji,
    required this.coverColorHex,
    this.address = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.distanceKm,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final String tagline;
  final BusinessCategory category;
  final String logoEmoji;

  /// Hex (e.g. `0xFF7B3F00`) used as the cover/brand color of the loyalty card.
  final int coverColorHex;

  final String address;
  final double rating;
  final int reviewCount;
  final double? distanceKm;
  final bool isFeatured;

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      tagline: (json['tagline'] as String?) ?? '',
      category: BusinessCategory.fromJson(
          (json['category'] as String?) ?? 'OTHER'),
      logoEmoji: (json['logoEmoji'] as String?) ?? '🏪',
      coverColorHex: (json['coverColorHex'] as num?)?.toInt() ?? 0xFF1F2937,
      address: (json['address'] as String?) ?? '',
      rating: ((json['rating'] as num?) ?? 0).toDouble(),
      reviewCount: ((json['reviewCount'] as num?) ?? 0).toInt(),
      isFeatured: (json['featured'] as bool?) ?? false,
    );
  }
}
