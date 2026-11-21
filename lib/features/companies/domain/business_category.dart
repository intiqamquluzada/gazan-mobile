import 'package:flutter/material.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';

/// Top-level service categories shown on the discover feed.
///
/// Matches the backend's `BusinessCategory` enum 1:1 — JSON wire form is
/// the upper-snake-case name (e.g. `"COFFEE"`).
enum BusinessCategory {
  // Only four categories own an accent colour (coffee amber, restaurant
  // rose, beauty purple, fitness teal); the rest share the neutral pair so
  // the palette never grows with the category list.
  coffee('COFFEE', 'Kafe & Qəhvəxana', Icons.coffee_outlined,
      AppColors.catCoffee, AppColors.catCoffeeBg),
  restaurant('RESTAURANT', 'Restoran', Icons.restaurant_outlined,
      AppColors.catRestaurant, AppColors.catRestaurantBg),
  beauty('BEAUTY', 'Gözəllik', Icons.spa_outlined, AppColors.catBeauty,
      AppColors.catBeautyBg),
  barber('BARBER', 'Bərbər', Icons.cut_outlined, AppColors.catNeutral,
      AppColors.catNeutralBg),
  carwash('CARWASH', 'Avtoyuma', Icons.local_car_wash_outlined,
      AppColors.catNeutral, AppColors.catNeutralBg),
  fitness('FITNESS', 'Fitness', Icons.fitness_center_outlined,
      AppColors.catTeal, AppColors.catTealBg),
  bakery('BAKERY', 'Şirniyyat', Icons.bakery_dining_outlined,
      AppColors.catNeutral, AppColors.catNeutralBg),
  other('OTHER', 'Digər', Icons.storefront_outlined, AppColors.catNeutral,
      AppColors.catNeutralBg);

  const BusinessCategory(
      this.wire, this.label, this.icon, this.tint, this.tintBg);

  /// JSON wire form sent over the API.
  final String wire;
  final String label;
  final IconData icon;

  /// Accent for text / icons on [tintBg] (AA-checked pairs).
  final Color tint;
  final Color tintBg;

  /// Localized display label for the current language.
  String labelOf(S s) {
    switch (this) {
      case BusinessCategory.coffee:
        return s.catCoffee;
      case BusinessCategory.restaurant:
        return s.catRestaurant;
      case BusinessCategory.beauty:
        return s.catBeauty;
      case BusinessCategory.barber:
        return s.catBarber;
      case BusinessCategory.carwash:
        return s.catCarwash;
      case BusinessCategory.fitness:
        return s.catFitness;
      case BusinessCategory.bakery:
        return s.catBakery;
      case BusinessCategory.other:
        return s.catOther;
    }
  }

  /// Short label for tight spots (the discover category strip).
  String shortLabelOf(S s) =>
      this == BusinessCategory.coffee ? s.catCoffeeShort : labelOf(s);

  String toJson() => wire;

  static BusinessCategory fromJson(String value) {
    for (final BusinessCategory c in values) {
      if (c.wire == value) return c;
    }
    return BusinessCategory.other;
  }
}
