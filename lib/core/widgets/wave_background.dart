import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The app's signature canvas: near-white mint with soft organic waves —
/// a large curve in the top-left corner, a lighter one top-right and a
/// wide wave along the bottom edge. Waves are light enough that text and
/// white cards on top keep full contrast.
///
/// Every page route gets this automatically through
/// [WavePageTransitionsBuilder]; use the widget directly only for surfaces
/// that are not routes (e.g. a full-screen overlay).
///
/// Pages inside a shell (bottom-nav tabs) are nested in the shell's own
/// background: they skip the bottom wave, so it shows only once — around
/// the floating navigation bar.
class WaveBackground extends StatelessWidget {
  const WaveBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final bool nested = context
            .dependOnInheritedWidgetOfExactType<_WaveScope>() !=
        null;
    final Widget painted = CustomPaint(
      painter: _WavePainter(
        bottomWave: !nested,
        background: p.background,
        strong: AppColors.waveStrong,
        soft: AppColors.waveSoft,
      ),
      child: child,
    );
    return nested ? painted : _WaveScope(child: painted);
  }
}

class _WaveScope extends InheritedWidget {
  const _WaveScope({required super.child});

  @override
  bool updateShouldNotify(_WaveScope oldWidget) => false;
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.bottomWave,
    required this.background,
    required this.strong,
    required this.soft,
  });

  final bool bottomWave;
  final Color background;
  final Color strong;
  final Color soft;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    // Keep the shapes phone-sized on tall / wide windows (desktop app).
    final double topH = (h * 0.24).clamp(120.0, 230.0);
    final double topW = (w * 0.62).clamp(180.0, 420.0);

    // Top-left curve.
    final Path topLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(topW, 0)
      ..cubicTo(topW * 0.72, topH * 0.18, topW * 0.52, topH * 0.62,
          topW * 0.22, topH * 0.86)
      ..quadraticBezierTo(topW * 0.08, topH * 0.98, 0, topH)
      ..close();
    canvas.drawPath(topLeft, Paint()..color = strong);

    // Lighter wave hugging the top-right corner.
    final double trH = topH * 0.48;
    final Path topRight = Path()
      ..moveTo(w, 0)
      ..lineTo(w - topW * 0.42, 0)
      ..cubicTo(w - topW * 0.18, trH * 0.08, w - topW * 0.10, trH * 0.70, w,
          trH)
      ..close();
    canvas.drawPath(topRight, Paint()..color = soft);

    if (!bottomWave) return;

    // Wide wave along the bottom.
    final double botH = (h * 0.12).clamp(70.0, 130.0);
    final Path bottom = Path()
      ..moveTo(0, h)
      ..lineTo(0, h - botH * 0.55)
      ..cubicTo(w * 0.28, h - botH * 1.05, w * 0.55, h - botH * 0.15, w,
          h - botH)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(bottom, Paint()..color = soft);
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.bottomWave != bottomWave ||
      old.background != background ||
      old.strong != strong ||
      old.soft != soft;
}

/// Wraps every page route in [WaveBackground] and then hands over to the
/// platform's usual transition, so the waves travel with the page and
/// transparent scaffolds never show the previous page through.
class WavePageTransitionsBuilder extends PageTransitionsBuilder {
  const WavePageTransitionsBuilder(this.inner);

  final PageTransitionsBuilder inner;

  static const PageTransitionsTheme theme = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android:
          WavePageTransitionsBuilder(ZoomPageTransitionsBuilder()),
      TargetPlatform.iOS:
          WavePageTransitionsBuilder(CupertinoPageTransitionsBuilder()),
      TargetPlatform.macOS:
          WavePageTransitionsBuilder(CupertinoPageTransitionsBuilder()),
      TargetPlatform.windows:
          WavePageTransitionsBuilder(ZoomPageTransitionsBuilder()),
      TargetPlatform.linux:
          WavePageTransitionsBuilder(ZoomPageTransitionsBuilder()),
      TargetPlatform.fuchsia:
          WavePageTransitionsBuilder(ZoomPageTransitionsBuilder()),
    },
  );

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return inner.buildTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      WaveBackground(child: child),
    );
  }
}
