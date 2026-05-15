import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
      emoji: '☕',
      title: AppStrings.onboardTitle1,
      subtitle: AppStrings.onboardSubtitle1,
      tint: Color(0xFFFFE7DC),
    ),
    _OnboardSlide(
      emoji: '📱',
      title: AppStrings.onboardTitle2,
      subtitle: AppStrings.onboardSubtitle2,
      tint: Color(0xFFD9F5F1),
    ),
    _OnboardSlide(
      emoji: '🎁',
      title: AppStrings.onboardTitle3,
      subtitle: AppStrings.onboardSubtitle3,
      tint: Color(0xFFFFF3CD),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index >= _slides.length - 1) {
      context.go('/role');
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextButton(
                  onPressed: () => context.go('/role'),
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
                label: _index == _slides.length - 1
                    ? AppStrings.getStarted
                    : AppStrings.continueAction,
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
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.tint,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color tint;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: slide.tint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(slide.emoji, style: const TextStyle(fontSize: 96)),
          ),
          const SizedBox(height: AppSpacing.huge),
          Text(slide.title,
              style: AppTextStyles.h1, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Text(slide.subtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center),
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
          width: active ? 22 : 8,
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
