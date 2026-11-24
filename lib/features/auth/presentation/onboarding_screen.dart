import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/brand_header.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  List<_OnboardSlide> _slidesOf(S s) => <_OnboardSlide>[
        _OnboardSlide(
          art: 'assets/illustrations/onb_shop.png',
          brand: true,
          before: s.onb1a,
          highlight: s.onb1b,
          after: s.onb1c,
          style: _Highlight.underline,
          body: s.onbBody1,
        ),
        _OnboardSlide(
          art: 'assets/illustrations/onb_nfc.png',
          before: s.onb2a,
          highlight: s.onb2b,
          after: s.onb2c,
          style: _Highlight.chip,
          body: s.onbBody2,
        ),
        _OnboardSlide(
          art: 'assets/illustrations/onb_gift.png',
          before: s.onb3a,
          highlight: s.onb3b,
          after: s.onb3c,
          style: _Highlight.underline,
          body: s.onbBody3,
        ),
      ];

  static const int _slideCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setBool('qazan.seen_onboarding', true);
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_index >= _slideCount - 1) {
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
    final S s = ref.watch(sProvider);
    final List<_OnboardSlide> slides = _slidesOf(s);
    final bool last = _index == slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.sm, AppSpacing.sm, 0),
              child: Row(
                children: <Widget>[
                  const BrandMark(size: 28),
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                      foregroundColor: context.palette.textPrimary,
                    ),
                    child: Text(
                      s.skip,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (int i) => setState(() => _index = i),
                itemCount: slides.length,
                itemBuilder: (BuildContext _, int i) =>
                    _SlideView(slide: slides[i]),
              ),
            ),
            _PageDots(count: slides.length, index: _index),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: PrimaryButton(
                label: last ? s.getStarted : s.continueAction,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Highlight { underline, chip }

class _OnboardSlide {
  const _OnboardSlide({
    required this.art,
    required this.before,
    required this.highlight,
    required this.after,
    required this.style,
    required this.body,
    this.brand = false,
  });

  /// 3D illustration (transparent PNG).
  final String art;
  final String before;
  final String highlight;
  final String after;
  final _Highlight style;
  final String body;

  /// First slide also carries the logo and word-mark above the art.
  final bool brand;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardSlide slide;

  @override
  Widget build(BuildContext context) {
    final TextStyle title = AppTextStyles.display.copyWith(
      color: context.palette.ink,
      fontWeight: FontWeight.w800,
      height: 1.25,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        // Shrink the art on short screens so the text never clips.
        final double artW = (c.maxHeight * 0.62).clamp(190.0, 330.0).toDouble();
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: artW,
                  height: artW * 0.82,
                  child: Image.asset(
                    slide.art,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text.rich(
                  TextSpan(
                    style: title,
                    children: <InlineSpan>[
                      TextSpan(text: slide.before),
                      if (slide.highlight.isNotEmpty)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: _Highlighted(
                            text: slide.highlight,
                            style: title,
                            kind: slide.style,
                          ),
                        ),
                      TextSpan(text: slide.after),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  slide.body,
                  style: AppTextStyles.body.copyWith(
                    color: context.palette.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The emphasised word in a slide title: accent colour with a hand-drawn
/// swoosh under it, or on an accent chip.
class _Highlighted extends StatelessWidget {
  const _Highlighted({
    required this.text,
    required this.style,
    required this.kind,
  });

  final String text;
  final TextStyle style;
  final _Highlight kind;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.caramel;
    final Text word = Text(text, style: style.copyWith(color: accent));
    if (kind == _Highlight.chip) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: context.palette.surfaceAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: word,
      );
    }
    return CustomPaint(
      foregroundPainter: _SwooshPainter(accent),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: word,
      ),
    );
  }
}

class _SwooshPainter extends CustomPainter {
  const _SwooshPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height - 3;
    final Path p = Path()
      ..moveTo(size.width * 0.02, y)
      ..quadraticBezierTo(size.width * 0.5, y - 9, size.width, y - 3);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SwooshPainter old) => old.color != color;
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
          width: active ? 22 : 16,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.caramel : context.palette.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
