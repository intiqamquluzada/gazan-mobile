import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1100), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: const Text('Q',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1,
                  )),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(AppStrings.appName,
                style: AppTextStyles.display.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                )),
            const SizedBox(height: AppSpacing.sm),
            Text(AppStrings.appTagline,
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                )),
          ],
        ),
      ),
    );
  }
}
