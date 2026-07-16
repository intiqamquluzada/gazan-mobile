import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../application/business_providers.dart';
import '../data/business_repository.dart';
import '../domain/customer_summary.dart';

class BusinessDashboardScreen extends ConsumerWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppUser? user = ref.watch(currentUserProvider);
    final AsyncValue<BusinessStats?> statsAsync =
        ref.watch(myBusinessStatsProvider);
    final AsyncValue<List<CustomerSummary>> customersAsync =
        ref.watch(myCustomersProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myBusinessStatsProvider);
            ref.invalidate(myCustomersProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(s.hello, style: AppTextStyles.bodySm),
                        const SizedBox(height: 2),
                        Text(user?.fullName ?? 'Biznes',
                            style: AppTextStyles.h1),
                      ],
                    ),
                  ),
                  // Tapping the avatar opens the owner's personal account
                  // settings (password change, language, sign-out) — not
                  // the public business profile.
                  InkWell(
                    onTap: () => context.push('/business/account'),
                    customBorder: const CircleBorder(),
                    child: Avatar(name: user?.fullName ?? 'B', size: 44),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              statsAsync.when(
                loading: () => const _StatsSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (BusinessStats? stats) {
                  if (stats == null) return const SizedBox.shrink();
                  return _StatsGrid(stats: stats, s: s);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              _PrimaryAction(
                title: s.scanCustomerQr,
                subtitle: s.scanTapHint,
                onScan: () => context.go('/business/scan'),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SectionHeader(
                title: s.recentCustomers,
                action: s.all,
                onAction: () => context.go('/business/customers'),
              ),
              const SizedBox(height: AppSpacing.md),
              customersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (Object e, _) => EmptyState(
                  title: s.error, subtitle: e.toString(),
                  icon: AppIcons.error,
                ),
                data: (List<CustomerSummary> list) {
                  if (list.isEmpty) {
                    return EmptyState(
                      title: s.noCustomersYet,
                      subtitle: s.firstCustomerHint,
                      icon: AppIcons.customers,
                    );
                  }
                  return Column(
                    children: <Widget>[
                      for (final CustomerSummary c in list.take(5))
                        _CustomerTile(c: c),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.s});

  final BusinessStats stats;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _StatTile(
                value: '${stats.activeCustomers}',
                label: s.activeCustomers,
                icon: AppIcons.customersActive,
                tint: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatTile(
                value: '${stats.stampsToday}',
                label: s.stampsToday,
                icon: Icons.bookmark_added_rounded,
                tint: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: _StatTile(
                value: '${stats.rewardsThisWeek}',
                label: s.rewardsWeek,
                icon: AppIcons.gift,
                tint: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatTile(
                value: '${(stats.repeatRate * 100).round()}%',
                label: s.returnRate,
                icon: Icons.replay_rounded,
                tint: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.tint,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: tint),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value,
              style: AppTextStyles.display.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.onScan,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onScan;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onScan,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(AppIcons.qr,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: AppTextStyles.h3.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySm.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      )),
                ],
              ),
            ),
            const Icon(AppIcons.forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _CustomerTile extends ConsumerWidget {
  const _CustomerTile({required this.c});

  final CustomerSummary c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push('/business/customers/${c.userId}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: <Widget>[
              Avatar(name: c.fullName, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.fullName, style: AppTextStyles.bodyLg),
                    Text(
                      '${c.totalVisits} ${s.visitsWord} · ${c.rewardsClaimed} ${s.rewardWord}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text('${c.totalStamps}',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
