import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/widgets/periodic_refresh.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/business_providers.dart';
import '../domain/customer_detail.dart';

/// Rich customer profile for the business owner — contact details,
/// lifetime stats, loyalty cards, and the recent purchase/activity feed
/// at *this* venue.
class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<CustomerDetail> async =
        ref.watch(customerDetailProvider(userId));

    // Customers keep earning while this screen is open.
    return PeriodicRefresh(
      onTick: () => ref.invalidate(customerDetailProvider(userId)),
      child: Scaffold(
      appBar: AppBar(title: Text(s.customerTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: s.notLoaded,
          subtitle: e.toString(),
          icon: AppIcons.error,
        ),
        data: (CustomerDetail c) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(customerDetailProvider(userId)),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: <Widget>[
              _Header(c: c),
              const SizedBox(height: AppSpacing.xl),
              _StatGrid(c: c),
              const SizedBox(height: AppSpacing.xxl),
              if (c.cards.isNotEmpty) ...<Widget>[
                Text(s.loyaltyCards, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                for (final CustomerCard card in c.cards)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _CardTile(card: card),
                  ),
                const SizedBox(height: AppSpacing.xxl),
              ],
              Text(s.recentPurchases, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              if (c.recentActivity.isEmpty)
                EmptyState(
                  title: s.noActivityYet,
                  subtitle: s.activityWillShow,
                  icon: AppIcons.programsActive,
                )
              else
                for (final CustomerActivity a in c.recentActivity)
                  _ActivityTile(a: a),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.c});

  final CustomerDetail c;

  Future<void> _call(String phone) async =>
      launchUrl(Uri(scheme: 'tel', path: phone));
  Future<void> _mail(String email) async =>
      launchUrl(Uri(scheme: 'mailto', path: email));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final bool hasPhone = (c.phone ?? '').trim().isNotEmpty;
    final bool hasEmail = (c.email ?? '').trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Avatar(name: c.fullName, size: 60),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.fullName.isEmpty ? s.unnamed : c.fullName,
                        style: AppTextStyles.h2),
                    if (hasEmail)
                      Text(c.email!,
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textSecondary)),
                    if (hasPhone)
                      Text(c.phone!,
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (hasPhone || hasEmail) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                if (hasPhone)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _call(c.phone!),
                      icon: const Icon(Icons.call_outlined, size: 18),
                      label: Text(s.callAction),
                    ),
                  ),
                if (hasPhone && hasEmail) const SizedBox(width: AppSpacing.sm),
                if (hasEmail)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _mail(c.email!),
                      icon: const Icon(Icons.alternate_email_rounded, size: 18),
                      label: Text(s.email),
                    ),
                  ),
              ],
            ),
          ],
          if (c.memberSince != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text('${s.memberSinceLabel} ${AppFormat.dateTime(c.memberSince!)}',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _StatGrid extends ConsumerWidget {
  const _StatGrid({required this.c});

  final CustomerDetail c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _StatTile(
                icon: Icons.bookmark_added_rounded,
                tint: AppColors.catTeal,
                value: '${c.totalStamps}',
                label: s.totalStampsLabel,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatTile(
                icon: AppIcons.gift,
                tint: AppColors.success,
                value: '${c.totalRewardsClaimed}',
                label: s.earnedRewards,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: _StatTile(
                icon: Icons.card_giftcard_rounded,
                tint: AppColors.action,
                value: '${c.rewardsAvailable}',
                label: s.readyReward,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatTile(
                icon: Icons.replay_rounded,
                tint: AppColors.catCoffee,
                value: '${c.totalVisits}',
                label: s.visitWord,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _StatTile(
          icon: AppIcons.token,
          tint: AppColors.reward,
          value: '${c.coinBalance}',
          label: s.coinLabel,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.tint,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color tint;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: tint),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTextStyles.display.copyWith(fontSize: 24)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _CardTile extends ConsumerWidget {
  const _CardTile({required this.card});

  final CustomerCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(card.programTitle,
                    style: AppTextStyles.bodyLg
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
              if (card.rewardsAvailable > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text('${card.rewardsAvailable} ${s.readyWord}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.successText,
                        fontWeight: FontWeight.w700,
                      )),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: card.progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceMuted,
              color: AppColors.action,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
              '${card.stamps} / ${card.stampsRequired} ${s.stampWord} · '
              '${card.totalRewardsClaimed} ${s.rewardWord}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({required this.a});

  final CustomerActivity a;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final bool isReward = a.isReward;
    final Color tint = isReward ? AppColors.success : AppColors.catTeal;
    final IconData icon =
        isReward ? AppIcons.gift : Icons.bookmark_added_rounded;
    final String title = isReward
        ? s.rewardGained
        : (a.amount > 1 ? '${a.amount}× ${s.stampAdded}' : s.stampAdded);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: tint),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: AppTextStyles.bodySm
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(
                  a.programTitle +
                      (a.note != null && a.note!.isNotEmpty
                          ? ' · ${a.note}'
                          : ''),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (a.at != null)
            Text(AppFormat.dateTime(a.at!),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
