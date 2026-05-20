import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _boot();
  }

  Future<void> _boot() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final bool seenOnboarding =
        p.getBool('qazan.seen_onboarding') ?? false;
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    // The router redirect sends authenticated users to their shell;
    // returning guests skip onboarding straight to role selection.
    context.go(seenOnboarding ? '/role' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: kHeroGradient),
        child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('Q',
                  style: TextStyle(
                    fontSize: 58,
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
      ),
    );
  }
}
