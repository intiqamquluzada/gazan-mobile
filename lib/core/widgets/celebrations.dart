import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icons.dart';

/// True when the OS asks for reduced motion — every celebration below
/// then jumps straight to its end state.
bool reduceMotionOf(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

// ─────────────────────────── Count-up balance ───────────────────────────

/// Shows [value], counting up from the last value this device saw (kept
/// under [storageKey]) over ~600 ms. When it grows, a short gold sparkle
/// bursts beside it and a green "+N" chip fades in and out.
class AnimatedBalance extends StatefulWidget {
  const AnimatedBalance({
    super.key,
    required this.value,
    required this.storageKey,
    required this.style,
    this.deltaSuffix = '',
  });

  final int value;
  final String storageKey;
  final TextStyle style;

  /// Appended to the "+N" chip (e.g. " coin").
  final String deltaSuffix;

  @override
  State<AnimatedBalance> createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends State<AnimatedBalance>
    with TickerProviderStateMixin {
  late final AnimationController _count = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  int _from = 0;
  int _to = 0;
  int _delta = 0;

  @override
  void initState() {
    super.initState();
    _from = _to = widget.value;
    _restoreAndAnimate();
  }

  Future<void> _restoreAndAnimate() async {
    int? last;
    try {
      last = (await SharedPreferences.getInstance()).getInt(widget.storageKey);
    } catch (_) {}
    if (!mounted) return;
    if (last != null && last < widget.value) {
      _animate(last, widget.value);
    }
    _persist(widget.value);
  }

  Future<void> _persist(int v) async {
    try {
      await (await SharedPreferences.getInstance())
          .setInt(widget.storageKey, v);
    } catch (_) {}
  }

  void _animate(int from, int to) {
    setState(() {
      _from = from;
      _to = to;
      _delta = to - from;
    });
    if (reduceMotionOf(context)) {
      _count.value = 1;
      return;
    }
    _count.forward(from: 0);
    _burst.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant AnimatedBalance old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      final int shown = _current;
      if (widget.value > shown) {
        _animate(shown, widget.value);
      } else {
        setState(() => _from = _to = widget.value);
        _count.value = 1;
      }
      _persist(widget.value);
    }
  }

  int get _current =>
      (_from + (_to - _from) * Curves.easeOutCubic.transform(_count.value))
          .round();

  @override
  void dispose() {
    _count.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _burst,
                  builder: (_, __) => CustomPaint(
                    painter: _SparklePainter(progress: _burst.value),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _count,
              builder: (_, __) => Text('$_current', style: widget.style),
            ),
          ],
        ),
        AnimatedBuilder(
          animation: _burst,
          builder: (_, __) {
            final double t = _burst.value;
            if (_delta <= 0 || t == 0 || t == 1) {
              return const SizedBox.shrink();
            }
            // fade in over the first 20 %, out over the last 30 %
            final double o = t < 0.2 ? t / 0.2 : (t > 0.7 ? (1 - t) / 0.3 : 1);
            return Opacity(
              opacity: o.clamp(0, 1),
              child: Container(
                margin: const EdgeInsets.only(left: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '+$_delta${widget.deltaSuffix}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.successText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// A ring of small gold sparks that fly out and fade.
class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final Offset c = size.center(Offset.zero);
    final double base = math.max(size.width, size.height) / 2;
    final double t = Curves.easeOut.transform(progress);
    final Paint p = Paint()
      ..color = AppColors.reward.withValues(alpha: (1 - progress) * 0.95);
    const int n = 10;
    for (int i = 0; i < n; i++) {
      final double a = (i / n) * 2 * math.pi + 0.3;
      final double r = base * (0.55 + 0.6 * t);
      final Offset o = c + Offset(math.cos(a) * r, math.sin(a) * r * 0.7);
      canvas.drawCircle(o, (i.isEven ? 3.2 : 2.2) * (1 - progress * 0.6), p);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.progress != progress;
}

// ─────────────────────────── Reward-ready sheet ───────────────────────────

/// Celebration sheet shown when a loyalty card is completed: reward-soft
/// background, big gift, message and a primary "use" button. Not full
/// screen — a bottom sheet the user can swipe away.
Future<void> showRewardReadySheet(
  BuildContext context, {
  required String title,
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.palette.rewardSoft,
    showDragHandle: true,
    builder: (BuildContext ctx) => _RewardReadySheet(
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: () {
        Navigator.of(ctx).pop();
        onAction();
      },
    ),
  );
}

class _RewardReadySheet extends StatefulWidget {
  const _RewardReadySheet({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  State<_RewardReadySheet> createState() => _RewardReadySheetState();
}

class _RewardReadySheetState extends State<_RewardReadySheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (reduceMotionOf(context)) {
        _in.value = 1;
      } else {
        _in.forward();
      }
    });
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> pop = CurvedAnimation(
      parent: _in,
      curve: Curves.elasticOut,
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 132,
              height: 132,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _in,
                      builder: (_, __) => CustomPaint(
                        painter: _SparklePainter(progress: _in.value),
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: pop,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.reward,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.brand(AppColors.reward),
                      ),
                      child: const Icon(AppIcons.gift,
                          size: 48, color: AppColors.onReward),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h1.copyWith(color: AppColors.onReward),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.onReward),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onAction,
                child: Text(widget.actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Remembers, per card, how many ready rewards the user has already been
/// celebrated for, so each newly completed card triggers the sheet once.
class RewardCelebrationLedger {
  const RewardCelebrationLedger._();

  static const String _prefix = 'qazan.celebrated_rewards.';

  /// Set when a card tap already showed the "gift ready" moment, so the
  /// cards screen does not show a second sheet for the same gift.
  static DateTime? _tapCelebratedAt;

  static void markCelebratedByTap() => _tapCelebratedAt = DateTime.now();

  /// Returns true (and records it) when [available] exceeds what was last
  /// celebrated for [cardId]. The first sighting of a card only records.
  static Future<bool> shouldCelebrate(String cardId, int available) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String key = '$_prefix$cardId';
      final int? seen = prefs.getInt(key);
      await prefs.setInt(key, available);
      final DateTime? tap = _tapCelebratedAt;
      if (tap != null && DateTime.now().difference(tap).inMinutes < 2) {
        return false; // already celebrated right after the tap
      }
      return seen != null && available > seen;
    } catch (_) {
      return false;
    }
  }
}
