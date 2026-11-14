import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// One destination in [AppBottomNav]. Set [prominent] on the primary
/// action (QR / Scan) — it renders as the raised coffee disc.
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.prominent = false,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool prominent;
}

/// Floating bottom navigation.
///
/// A rounded white bar hovering above the canvas. A soft capsule slides
/// (with a little spring) behind the active tab, the chosen icon pops,
/// and the prominent action is a raised coffee disc with a slow
/// "breathing" glow. Every tap gives a light haptic tick. With the OS
/// "reduce motion" setting on, all motion snaps instantly.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const double _barHeight = 66;
  static const double _discOverhang = 20;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final bool reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final bool hasDisc = items.any((AppNavItem i) => i.prominent);
    final bool activeIsDisc = items[currentIndex].prominent;

    void tap(int i) {
      HapticFeedback.selectionClick();
      onSelect(i);
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
        child: SizedBox(
          height: _barHeight + (hasDisc ? _discOverhang : 0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double cell = c.maxWidth / items.length;
              const double pillW = 54;
              const double pillH = 34;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  // The bar itself.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: _barHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        border: Border.all(color: p.border),
                        boxShadow: AppShadows.md,
                      ),
                    ),
                  ),
                  // Sliding capsule behind the active (non-disc) tab.
                  AnimatedPositioned(
                    duration: reduce
                        ? Duration.zero
                        : const Duration(milliseconds: 420),
                    curve: Curves.easeOutBack,
                    left: currentIndex * cell + (cell - pillW) / 2,
                    bottom: _barHeight - pillH - 9,
                    width: pillW,
                    height: pillH,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: activeIsDisc ? 0 : 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: p.surfaceAccent,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                    ),
                  ),
                  // Tabs.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: _barHeight,
                    child: Row(
                      children: <Widget>[
                        for (int i = 0; i < items.length; i++)
                          Expanded(
                            child: items[i].prominent
                                ? const SizedBox.shrink()
                                : _Tab(
                                    item: items[i],
                                    selected: i == currentIndex,
                                    reduceMotion: reduce,
                                    onTap: () => tap(i),
                                  ),
                          ),
                      ],
                    ),
                  ),
                  // Raised disc for the prominent action.
                  for (int i = 0; i < items.length; i++)
                    if (items[i].prominent)
                      Positioned(
                        left: i * cell,
                        width: cell,
                        // A labelled disc sits a bit higher so its caption
                        // stays inside the bar.
                        top: items[i].label.isEmpty ? 0 : -8,
                        child: _Disc(
                          item: items[i],
                          selected: i == currentIndex,
                          reduceMotion: reduce,
                          onTap: () => tap(i),
                        ),
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.selected,
    required this.reduceMotion,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Color iconColor = selected ? p.caramel : p.textTertiary;
    final Duration d =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 260);

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 34,
              child: Center(
                // Pop: the icon briefly overshoots when it becomes active.
                child: TweenAnimationBuilder<double>(
                  key: ValueKey<bool>(selected),
                  tween: Tween<double>(begin: selected ? 0.7 : 1, end: 1),
                  duration: selected && !reduceMotion
                      ? const Duration(milliseconds: 450)
                      : Duration.zero,
                  curve: Curves.elasticOut,
                  builder: (BuildContext _, double sc, Widget? child) =>
                      Transform.scale(scale: sc, child: child),
                  child: AnimatedSwitcher(
                    duration: d,
                    child: Icon(
                      selected ? item.activeIcon : item.icon,
                      key: ValueKey<bool>(selected),
                      size: 23,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: d,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: selected ? p.caramelText : p.textTertiary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Raised coffee disc with a slow breathing glow; squishes on press.
class _Disc extends StatefulWidget {
  const _Disc({
    required this.item,
    required this.selected,
    required this.reduceMotion,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  State<_Disc> createState() => _DiscState();
}

class _DiscState extends State<_Disc> with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBreath();
  }

  @override
  void didUpdateWidget(covariant _Disc old) {
    super.didUpdateWidget(old);
    _syncBreath();
  }

  void _syncBreath() {
    if (widget.reduceMotion) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    const double size = 58;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.item.label.isEmpty ? 'NFC' : widget.item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: size + 16,
              height: size + 16,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // Breathing glow ring.
                  AnimatedBuilder(
                    animation: _breath,
                    builder: (_, __) {
                      final double t =
                          Curves.easeInOut.transform(_breath.value);
                      return Container(
                        width: size + 6 + 10 * t,
                        height: size + 6 + 10 * t,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.caramel
                              .withValues(alpha: 0.10 + 0.12 * (1 - t)),
                        ),
                      );
                    },
                  ),
                  AnimatedScale(
                    scale: _pressed ? 0.9 : 1,
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.heroGradient,
                        ),
                        border: Border.all(color: p.surface, width: 3),
                        boxShadow: AppShadows.brand(AppColors.surfaceDark),
                      ),
                      child: Icon(widget.item.activeIcon,
                          color: AppColors.onDark, size: 26),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.item.label.isNotEmpty)
              Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: widget.selected ? p.caramelText : p.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
