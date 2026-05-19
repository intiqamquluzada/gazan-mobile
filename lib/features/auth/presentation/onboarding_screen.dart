import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const List<_OnboardSlide> _slides = <_OnboardSlide>[
    _OnboardSlide(
      icon: AppIcons.store,
      title: AppStrings.onboardTitle1,
      subtitle: AppStrings.onboardSubtitle1,
    ),
    _OnboardSlide(
      icon: AppIcons.qr,
      title: AppStrings.onboardTitle2,
      subtitle: AppStrings.onboardSubtitle2,
    ),
    _OnboardSlide(
      icon: AppIcons.gift,
      title: AppStrings.onboardTitle3,
      subtitle: AppStrings.onboardSubtitle3,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setBool('qazan.seen_onboarding', true);
    if (mounted) context.go('/role');
  }

  void _next() {
    if (_index >= _slides.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool last = _index == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Keç'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (int i) => setState(() => _index = i),
                itemCount: _slides.length,
                itemBuilder: (BuildContext _, int i) =>
                    _SlideView(slide: _slides[i]),
              ),
            ),
            _PageDots(count: _slides.length, index: _index),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: PrimaryButton(
                label: last ? AppStrings.getStarted : AppStrings.continueAction,
                icon: last ? null : AppIcons.forward,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide {
  const _OnboardSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Layered icon mark: soft outer halo → tinted disc → glyph.
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 240,
                  height: 240,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySofter,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 168,
                  height: 168,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 104,
                  height: 104,
                  decoration: const BoxDecoration(
                    gradient: kHeroGradient,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x33F5560A),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(slide.icon, color: Colors.white, size: 46),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
          Text(
            slide.title,
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            slide.subtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
