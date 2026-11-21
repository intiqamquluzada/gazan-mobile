import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/celebrations.dart';
import '../data/nfc_repository.dart';

enum NfcCelebrationKind { stamp, coin, cardComplete, rewardUsed }

/// What the full-screen overlay should say.
class NfcCelebration {
  const NfcCelebration({
    required this.kind,
    required this.companyName,
    this.amount = 0,
    this.stampsNow,
    this.stampsRequired,
    this.detail,
    this.rewardTitle,
    this.venueBalance,
  });

  final NfcCelebrationKind kind;
  final String companyName;
  final int amount;
  final int? stampsNow;
  final int? stampsRequired;
  final String? detail;

  /// The gift a completed card unlocked, e.g. "Free coffee".
  final String? rewardTitle;

  /// Coins the customer now has at this venue (coins are per venue).
  final int? venueBalance;

  factory NfcCelebration.fromResult(NfcTapResult r) {
    final NfcCelebrationKind kind = r.rewardUnlocked
        ? NfcCelebrationKind.cardComplete
        : r.isStamp
            ? NfcCelebrationKind.stamp
            : NfcCelebrationKind.coin;
    return NfcCelebration(
      kind: kind,
      companyName: r.companyName,
      amount: r.isStamp ? r.stampsAdded : r.pointsAdded,
      stampsNow: r.stampsNow,
      stampsRequired: r.stampsRequired,
      detail: r.programTitle,
      rewardTitle: r.unlockedRewardTitle,
      venueBalance: r.isStamp ? null : r.pointsBalance,
    );
  }

  bool get leadsToRewards =>
      kind == NfcCelebrationKind.cardComplete;
}

/// Full-screen confetti moment after a successful tap, on top of any screen.
Future<void> showNfcCelebration(
  BuildContext context,
  NfcCelebration data, {
  VoidCallback? onViewRewards,
}) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'celebration',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (_, Animation<double> a, __, Widget child) =>
        FadeTransition(opacity: a, child: child),
    pageBuilder: (BuildContext dialogContext, _, __) => _CelebrationView(
      data: data,
      onViewRewards: onViewRewards,
    ),
  );
}

class _CelebrationView extends ConsumerStatefulWidget {
  const _CelebrationView({required this.data, this.onViewRewards});

  final NfcCelebration data;
  final VoidCallback? onViewRewards;

  @override
  ConsumerState<_CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends ConsumerState<_CelebrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  late final List<_Piece> _pieces = _Piece.scatter(
    widget.data.kind == NfcCelebrationKind.cardComplete ? 110 : 60,
  );
  Timer? _autoClose;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotionOf(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
    // Moments that offer a next step stay until the customer answers.
    if (!widget.data.leadsToRewards) {
      _autoClose = Timer(const Duration(milliseconds: 3200), _close);
    }
  }

  void _close() {
    if (mounted) Navigator.of(context, rootNavigator: true).maybePop();
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    _c.dispose();
    super.dispose();
  }

  ({IconData icon, String title, Color tint}) _look(S s) {
    final NfcCelebration d = widget.data;
    switch (d.kind) {
      case NfcCelebrationKind.stamp:
        return (
          icon: Icons.approval_rounded,
          title: '+${d.amount} ${s.stampWord}',
          tint: AppColors.caramel,
        );
      case NfcCelebrationKind.coin:
        return (
          icon: Icons.toll_rounded,
          title: '+${d.amount} ${s.coinLabel}',
          tint: AppColors.reward,
        );
      case NfcCelebrationKind.cardComplete:
        return (
          icon: Icons.emoji_events_rounded,
          title: s.rewardReadyTitle,
          tint: AppColors.reward,
        );
      case NfcCelebrationKind.rewardUsed:
        return (
          icon: Icons.check_circle_rounded,
          title: s.rewardUsedTitle,
          tint: AppColors.success,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final NfcCelebration d = widget.data;
    final ({IconData icon, String title, Color tint}) look = _look(s);
    final AppPalette p = context.palette;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(_pieces, _c.value),
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _c,
                curve: const Interval(0, 0.25, curve: Curves.elasticOut),
              ),
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.xxl),
                padding: const EdgeInsets.all(AppSpacing.xxl),
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: look.tint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(look.icon,
                          size: 54, color: AppColors.onReward),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(look.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display),
                    const SizedBox(height: AppSpacing.xs),
                    Text(d.companyName,
                        textAlign: TextAlign.center, style: AppTextStyles.h3),
                    if (d.detail != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Text(d.detail!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySm
                              .copyWith(color: p.textSecondary)),
                    ],
                    if (d.kind == NfcCelebrationKind.stamp &&
                        d.stampsNow != null &&
                        d.stampsRequired != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      _StampDots(
                          filled: d.stampsNow!, total: d.stampsRequired!),
                      const SizedBox(height: AppSpacing.xs),
                      Text('${d.stampsNow}/${d.stampsRequired}',
                          style: AppTextStyles.bodySm),
                    ],
                    if (d.kind == NfcCelebrationKind.coin &&
                        d.venueBalance != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Text(s.coinsAtVenue(d.venueBalance!),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700)),
                    ],
                    if (d.kind == NfcCelebrationKind.cardComplete) ...<Widget>[
                      if (d.stampsRequired != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.lg),
                        // The card that just filled up, every stamp in.
                        _StampDots(
                            filled: d.stampsRequired!,
                            total: d.stampsRequired!),
                        const SizedBox(height: AppSpacing.xs),
                        Text('${d.stampsRequired}/${d.stampsRequired}',
                            style: AppTextStyles.bodySm),
                      ],
                      if (d.rewardTitle != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        Text(d.rewardTitle!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.caramel)),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Text(s.rewardReadyBody,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySm),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    if (d.leadsToRewards)
                      FilledButton(
                        onPressed: () {
                          _close();
                          widget.onViewRewards?.call();
                        },
                        child: Text(s.viewMyRewards),
                      )
                    else
                      TextButton(onPressed: _close, child: Text(s.close)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StampDots extends StatelessWidget {
  const _StampDots({required this.filled, required this.total});

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        for (int i = 0; i < total; i++)
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? AppColors.caramel : AppColors.stampEmpty,
            ),
          ),
      ],
    );
  }
}

class _Piece {
  const _Piece(this.x, this.delay, this.speed, this.size, this.spin, this.color);

  final double x;
  final double delay;
  final double speed;
  final double size;
  final double spin;
  final Color color;

  static const List<Color> _colors = <Color>[
    AppColors.reward,
    AppColors.caramel,
    AppColors.success,
    AppColors.catRestaurant,
    AppColors.catTeal,
  ];

  static List<_Piece> scatter(int count) {
    final math.Random r = math.Random();
    return List<_Piece>.generate(
      count,
      (int i) => _Piece(
        r.nextDouble(),
        r.nextDouble() * 0.35,
        0.8 + r.nextDouble() * 0.7,
        6 + r.nextDouble() * 8,
        (r.nextDouble() - 0.5) * 14,
        _colors[i % _colors.length],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final Paint paint = Paint();
    for (final _Piece p in pieces) {
      final double local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final double y = -20 + (size.height + 40) * local * p.speed;
      final double x =
          p.x * size.width + math.sin(local * 9 + p.spin) * 18;
      paint.color = p.color.withValues(alpha: (1 - local).clamp(0.0, 1.0));
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(local * p.spin)
        ..drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.55),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
