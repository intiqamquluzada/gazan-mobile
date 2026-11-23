import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/platform/app_variant.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/qazan_logo.dart';
import '../application/auth_controller.dart';
import '../domain/user_role.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final bool seenOnboarding = p.getBool('qazan.seen_onboarding') ?? false;

    // Hold the splash for a minimum beat *and* until the session restore
    // settles, so a returning user lands directly on their shell instead
    // of flashing the role picker. The restore is capped so a slow/offline
    // network can never trap the user on the splash.
    await Future.wait<void>(<Future<void>>[
      Future<void>.delayed(const Duration(milliseconds: 1100)),
      ref
          .read(authControllerProvider.notifier)
          .restored
          .timeout(const Duration(seconds: 6), onTimeout: () {}),
    ]);
    if (!mounted) return;

    final AuthState auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) {
      context.go(auth.user!.role.landingPath);
      return;
    }
    // Returning guests (and the desktop till app) go straight to sign-in.
    context.go(
        seenOnboarding || AppVariant.isBusinessApp ? '/login' : '/onboarding');
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
              const _LogoBadge(),
              const SizedBox(height: AppSpacing.xl),
              Text(AppStrings.appName,
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.onDark,
                    fontSize: 36,
                  )),
              const SizedBox(height: AppSpacing.sm),
              Text(AppStrings.appTagline,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onDark.withValues(alpha: 0.85),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// The splash brand stamp — the animated pot-of-gold logo.
class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) =>
      const QazanLogo(size: 128, onDark: true);
}
