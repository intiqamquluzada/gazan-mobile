import 'package:flutter/material.dart';

/// Brand and semantic colors.
///
/// Palette modelled on the violet reference design: one confident purple
/// carries all emphasis over a near-white, low-chroma canvas. Tints are
/// soft lavender; a warm magenta is the only secondary accent (used for
/// the "rewards / dessert" family).
class AppColors {
  const AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C2BD9);
  static const Color primaryDark = Color(0xFF561FB0);
  static const Color primaryDeep = Color(0xFF3D1486);
  static const Color primarySoft = Color(0xFFEEE8FB); // tinted icon discs
  static const Color primarySofter = Color(0xFFF7F3FD); // section bg
  static const Color accent = Color(0xFFE0356E); // magenta — rewards

  /// Gradient for hero/header surfaces, the splash, the prominent QR.
  static const List<Color> heroGradient = <Color>[
    Color(0xFF7C3AED),
    Color(0xFF5B21B6),
  ];

  // ── Neutrals — light ───────────────────────────────────────────────
  static const Color background = Color(0xFFF7F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF2F0F7);
  static const Color border = Color(0xFFEAE8F0);
  static const Color borderStrong = Color(0xFFDAD7E5);

  // ── Neutrals — dark ────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF100E16);
  static const Color surfaceDark = Color(0xFF1A1722);
  static const Color surfaceAltDark = Color(0xFF231F2E);
  static const Color borderDark = Color(0xFF2E2A3A);

  // ── Text ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF171221);
  static const Color textSecondary = Color(0xFF6B6577);
  static const Color textTertiary = Color(0xFF9D97AB);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFF4F2F8);
  static const Color textSecondaryDark = Color(0xFFB1ACBE);

  // ── Semantic ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF1FB46A);
  static const Color warning = Color(0xFFF5A524);
  static const Color error = Color(0xFFE0356E);
  static const Color info = Color(0xFF6C2BD9);

  /// Base shadow tint — a desaturated indigo reads cleaner than black.
  static const Color shadow = Color(0xFF1A1230);
}
