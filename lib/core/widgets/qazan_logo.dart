import 'package:flutter/material.dart';

/// The Qazan brand mark — the pot of gold, cut out on a transparent
/// background, with a soft entrance pop and a gentle idle float.
///
/// The artwork is a raster (`assets/branding/qazan_mark.png`), so it reads
/// the same on light, dark and brand-gradient surfaces. Pass `animate: false` for a static mark
/// (dense rows, headers that rebuild often).
class QazanLogo extends StatefulWidget {
  const QazanLogo({
    super.key,
    this.size = 96,
    this.onDark = false,
    this.animate = true,
  });

  static const String asset = 'assets/branding/qazan_mark.png';

  /// Edge length of the square the mark is fitted into, in logical pixels.
  final double size;

  /// Kept for call sites; the cut-out mark needs no per-surface variant.
  final bool onDark;

  /// Run the entrance + idle animations. `false` renders the final frame.
  final bool animate;

  @override
  State<QazanLogo> createState() => _QazanLogoState();
}

class _QazanLogoState extends State<QazanLogo> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _intro.forward();
      _float.repeat(reverse: true);
    } else {
      _intro.value = 1;
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    final Widget tile = Image.asset(
      QazanLogo.asset,
      width: s,
      height: s,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Qazan',
    );
    if (!widget.animate) return SizedBox.square(dimension: s, child: tile);

    final Animation<double> pop =
        CurvedAnimation(parent: _intro, curve: Curves.easeOutBack);
    final Animation<double> bob =
        CurvedAnimation(parent: _float, curve: Curves.easeInOut);
    return SizedBox.square(
      dimension: s,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_intro, _float]),
        builder: (BuildContext context, Widget? child) => Opacity(
          opacity: _intro.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -s * 0.025 * bob.value),
            child: Transform.scale(scale: 0.7 + 0.3 * pop.value, child: child),
          ),
        ),
        child: tile,
      ),
    );
  }
}
