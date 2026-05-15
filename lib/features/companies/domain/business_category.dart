import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Top-level service categories shown on the discover feed.
///
/// Matches the backend's `BusinessCategory` enum 1:1 — JSON wire form is
/// the upper-snake-case name (e.g. `"COFFEE"`).
enum BusinessCategory {
  coffee('COFFEE', 'Kafe & Qəhvəxana', Icons.coffee_outlined, Color(0xFFB45309)),
  restaurant('RESTAURANT', 'Restoran', Icons.restaurant_outlined, Color(0xFFDC2626)),
  beauty('BEAUTY', 'Gözəllik', Icons.spa_outlined, Color(0xFFDB2777)),
  barber('BARBER', 'Bərbər', Icons.cut_outlined, Color(0xFF1F2937)),
  carwash('CARWASH', 'Avtoyuma', Icons.local_car_wash_outlined, Color(0xFF0284C7)),
  fitness('FITNESS', 'Fitness', Icons.fitness_center_outlined, Color(0xFF059669)),
  bakery('BAKERY', 'Şirniyyat', Icons.bakery_dining_outlined, Color(0xFFD97706)),
  other('OTHER', 'Digər', Icons.storefront_outlined, AppColors.primary);

  const BusinessCategory(this.wire, this.label, this.icon, this.tint);

  /// JSON wire form sent over the API.
  final String wire;
  final String label;
  final IconData icon;
  final Color tint;

  String toJson() => wire;

  static BusinessCategory fromJson(String value) {
    for (final BusinessCategory c in values) {
      if (c.wire == value) return c;
    }
    return BusinessCategory.other;
  }
}
