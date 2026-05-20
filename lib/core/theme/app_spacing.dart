import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 4-pt baseline spacing scale used across the app.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

/// Border radius scale. Cards and sheets use [xl]; pills use [full].
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;
}

/// Soft, layered elevation. We render shadows explicitly on containers
/// instead of relying on Material tonal elevation — it reads cleaner on
/// a light, low-chroma background and stays consistent in dark mode.
class AppShadows {
  const AppShadows._();

  /// Resting elevation for list cards.
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F101828),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  /// Raised surfaces — feature cards, sheets, the floating nav button.
  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(
      color: Color(0x14101828),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Brand-tinted glow under primary CTAs and the hero balance card.
  static List<BoxShadow> brand(Color color) => <BoxShadow>[
        BoxShadow(
          color: color.withValues(alpha: 0.32),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];
}

/// Convenience: the canonical screen edge padding.
const EdgeInsets kScreenPadding =
    EdgeInsets.symmetric(horizontal: AppSpacing.xl);

/// Convenience: the brand hero gradient as a [LinearGradient].
const LinearGradient kHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: AppColors.heroGradient,
);
