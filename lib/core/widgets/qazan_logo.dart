import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Animated Qazan brand mark — a stamped "coin" **Q** on a rounded tile,
/// with an entrance pop, a stroke that draws itself in, and a continuous
/// light bead that sweeps around the ring.
///
/// Two surfaces:
/// * [onDark] `true`  — white tile, gradient-filled Q (splash / hero).
/// * [onDark] `false` — gradient tile, white Q (light auth screens).
///
/// Pass `animate: false` for a static stamp (icons, dense lists).
class QazanLogo extends StatefulWidget {
  const QazanLogo({
    super.key,
    this.size = 96,
    this.onDark = false,
    this.animate = true,
  });

  /// Edge length of the rounded tile, in logical pixels.
  final double size;

  /// `true` when placed on a dark / brand-gradient surface.
  final bool onDark;

  /// Run the entrance + idle animations. `false` renders the final frame.
  final bool animate;

  @override
  State<QazanLogo> createState() => _QazanLogoState();
}

class _QazanLogoState extends State<QazanLogo> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    if (widget.animate) {
      _intro.forward();
      _sweep.repeat();
    } else {
      _intro.value = 1;
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> pop =
        CurvedAnimation(parent: _intro, curve: Curves.easeOutBack);

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_intro, _sweep]),
      builder: (BuildContext context, _) {
        final double appear = _intro.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: appear,
          child: Transform.scale(
            scale: 0.62 + 0.38 * pop.value,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _QazanLogoPainter(
                onDark: widget.onDark,
                sweep: _sweep.value,
                draw: Curves.easeOutCubic.transform(appear),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QazanLogoPainter extends CustomPainter {
  _QazanLogoPainter({
    required this.onDark,
    required this.sweep,
    required this.draw,
  });

  /// White tile + gradient Q when `true`; gradient tile + white Q otherwise.
  final bool onDark;

  /// Idle phase, 0..1 — rotation of the light bead.
  final double sweep;

  /// Entrance progress, 0..1 — how much of the ring + tail is drawn.
  final double draw;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Rect bounds = Offset.zero & size;
    final RRect tile =
        RRect.fromRectAndRadius(bounds, Radius.circular(s * 0.28));

    // ── Tile ──────────────────────────────────────────────────────────
    final Paint tilePaint = Paint();
    if (onDark) {
      tilePaint.color = Colors.white;
    } else {
      tilePaint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.heroGradient,
      ).createShader(bounds);
    }
    canvas.drawRRect(tile, tilePaint);

    // Top sheen — a faint glassy highlight across the upper half.
    canvas.drawRRect(
      tile,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: <Color>[
            Colors.white.withValues(alpha: onDark ? 0.0 : 0.16),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(bounds),
    );

    // ── The Q ─────────────────────────────────────────────────────────
    final Offset c = Offset(s * 0.5, s * 0.475);
    final double r = s * 0.255;
    final double stroke = s * 0.135;
    final Color qColor = onDark ? AppColors.primary : Colors.white;

    final Rect ringRect = Rect.fromCircle(center: c, radius: r);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = qColor;

    // Ring draws itself in like a forming coin.
    canvas.drawArc(ringRect, -math.pi / 2, 2 * math.pi * draw, false, ring);

    // The Q tail — a short thick diagonal that punches out lower-right,
    // arriving just as the ring closes.
    if (draw > 0.82) {
      final double tp = ((draw - 0.82) / 0.18).clamp(0.0, 1.0);
      const double diag = math.pi / 4;
      final Offset start = Offset(
        c.dx + r * math.cos(diag) * 0.42,
        c.dy + r * math.sin(diag) * 0.42,
      );
      final Offset end = Offset(
        c.dx + (r + stroke * 0.65) * math.cos(diag),
        c.dy + (r + stroke * 0.65) * math.sin(diag),
      );
      canvas.drawLine(
        start,
        Offset.lerp(start, end, tp)!,
        Paint()
          ..color = qColor
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── Idle light bead sweeping the ring (after the entrance) ─────────
    if (draw >= 0.999) {
      canvas.drawArc(
        ringRect,
        -math.pi / 2,
        2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            transform: GradientRotation(sweep * 2 * math.pi),
            colors: <Color>[
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: onDark ? 0.5 : 0.85),
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const <double>[0.0, 0.07, 0.2],
          ).createShader(ringRect),
      );
    }
  }

  @override
  bool shouldRepaint(_QazanLogoPainter old) =>
      old.sweep != sweep || old.draw != draw || old.onDark != onDark;
}
