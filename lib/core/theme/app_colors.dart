import 'package:flutter/material.dart';

/// Brand and semantic colors used across the app.
///
/// Kept separate from [ThemeData] so widgets can reference brand colors
/// without depending on a particular theme mode.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFFFF6F3C);
  static const Color primaryDark = Color(0xFFE85A22);
  static const Color primarySoft = Color(0xFFFFE7DC);
  static const Color accent = Color(0xFF2EC4B6);

  // Neutrals — light
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF4F4F6);
  static const Color border = Color(0xFFEDEDF1);

  // Neutrals — dark
  static const Color backgroundDark = Color(0xFF0F0F14);
  static const Color surfaceDark = Color(0xFF1B1B23);
  static const Color surfaceAltDark = Color(0xFF24242E);
  static const Color borderDark = Color(0xFF2C2C38);

  // Text
  static const Color textPrimary = Color(0xFF0F0F14);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFF5F5F7);
  static const Color textSecondaryDark = Color(0xFFB4B4BE);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
