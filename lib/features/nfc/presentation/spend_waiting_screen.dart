import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../rewards/application/rewards_providers.dart';
import '../../wallet/application/wallet_providers.dart';
import '../data/nfc_repository.dart';
import 'nfc_celebration.dart';

/// After the customer taps the venue's "spend" card: their rewards are on
/// the cashier's screen, and this page waits until they are marked used.
class SpendWaitingScreen extends ConsumerStatefulWidget {
  const SpendWaitingScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<SpendWaitingScreen> createState() => _SpendWaitingState();
}

class _SpendWaitingState extends ConsumerState<SpendWaitingScreen> {
  Timer? _timer;
  SpendStatus? _status;
  String? _error;
  int _celebrated = 0;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    unawaited(_poll());
    _timer =
        Timer.periodic(const Duration(seconds: 3), (_) => unawaited(_poll()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      final SpendStatus st = await ref
          .read(nfcRepositoryProvider)
          .spendStatus(widget.sessionId);
      if (!mounted) return;
      final bool newlyUsed =
          _initialised && st.usedTitles.length > _celebrated;
      setState(() {
        _status = st;
        _error = null;
        _celebrated = st.usedTitles.length;
        _initialised = true;
      });
      if (newlyUsed) {
        // A used stamp gift also clears the "gift waiting" badge on the
        // cards list, so cards reload too.
        ref
          ..invalidate(coinSummaryProvider)
          ..invalidate(myCardsProvider)
          ..invalidate(myActiveRewardsProvider)
          ..invalidate(myUsedRewardsProvider);
        unawaited(showNfcCelebration(
          context,
          NfcCelebration(
            kind: NfcCelebrationKind.rewardUsed,
            companyName: st.companyName,
            detail: st.usedTitles.last,
          ),
        ));
      }
      if (!st.isOpen) {
        _timer?.cancel();
        ref
          ..invalidate(myCardsProvider)
          ..invalidate(myActiveRewardsProvider);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    final SpendStatus? st = _status;
    return Scaffold(
      appBar: AppBar(title: Text(s.spendWaitingTitle)),
      body: st == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Text(_error!, textAlign: TextAlign.center),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: <Widget>[
                Icon(
                  st.isOpen
                      ? Icons.hourglass_top_rounded
                      : st.isExpired
                          ? Icons.timer_off_rounded
                          : Icons.check_circle_rounded,
                  size: 64,
                  color: st.isOpen
                      ? AppColors.caramel
                      : st.isExpired
                          ? AppColors.dangerText
                          : AppColors.success,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  st.isOpen
                      ? s.spendWaitingBody
                      : st.isExpired
                          ? s.spendExpiredTitle
                          : s.spendFinished,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2,
                ),
                if (st.isExpired) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(s.spendExpiredBody,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(st.companyName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body
                        .copyWith(color: p.textSecondary)),
                const SizedBox(height: AppSpacing.xxl),
                if (st.rewards.isNotEmpty) ...<Widget>[
                  Text(s.spendYourRewards, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  for (final String title in st.rewards)
                    _Row(icon: Icons.card_giftcard_rounded, title: title),
                ],
                if (st.usedTitles.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Text(s.spendUsedNow, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  for (final String title in st.usedTitles)
                    _Row(icon: Icons.check_rounded, title: title),
                ],
                if (!st.isOpen) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(s.close),
                  ),
                ],
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.caramel),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(title, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
