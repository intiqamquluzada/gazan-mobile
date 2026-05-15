import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized text styles. Built on top of [GoogleFonts.inter] to get a
/// consistent, readable type scale.
class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get display => GoogleFonts.inter(
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: AppColors.textSecondary,
      );
}
