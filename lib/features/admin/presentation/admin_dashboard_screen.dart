import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/application/auth_controller.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'admin_widgets.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final S s = ref.read(sProvider);
    final bool ok = await showConfirmSheet(
      context,
      title: s.logoutTitle,
      body: s.signOutAdminBody,
      confirmLabel: s.logout,
      cancelLabel: s.stay,
    );
    if (ok) {
      // Router's auth refresh listener handles the redirect to /role.
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<AdminStats?> statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminStatsProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(s.qazanAdmin, style: AppTextStyles.bodySm),
                        const SizedBox(height: 2),
                        Text(s.platformPanel, style: AppTextStyles.h1),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: s.logout,
                    icon: const Icon(AppIcons.logout),
                    onPressed: () => _signOut(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              statsAsync.when(
                loading: () => const _DashboardSkeleton(),
                error: (Object e, _) => EmptyState(
                  title: s.notLoaded,
                  subtitle: e.toString(),
                  icon: AppIcons.error,
                ),
                data: (AdminStats? stats) {
                  if (stats == null) {
                    return EmptyState(
                      title: s.noData,
                      subtitle: s.statsUnavailable,
                      icon: AppIcons.info,
                    );
                  }
                  return _Dashboard(stats: stats);
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

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Content management shortcuts.
        Row(
          children: <Widget>[
            Expanded(
              child: _MgmtCard(
                icon: AppIcons.star,
                label: s.promotions,
                tint: AppColors.warning,
                onTap: () => context.go('/admin/promotions'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MgmtCard(
                icon: Icons.restaurant_menu_rounded,
                label: s.menus,
                tint: AppColors.accent,
                onTap: () => context.go('/admin/menus'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: <Widget>[
            Expanded(
              child: AdminStatTile(
                value: '${stats.totalUsers}',
                label: s.usersLabel,
                icon: AppIcons.customersActive,
                tint: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AdminStatTile(
                value: '${stats.totalCompanies}',
                label: s.businessLabel,
                icon: AppIcons.store,
                tint: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: AdminStatTile(
                value: '${stats.totalLoyaltyCards}',
                label: s.loyaltyCard,
                icon: AppIcons.programsActive,
                tint: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AdminStatTile(
                value: '${stats.coinTransactions}',
                label: s.coinTransaction,
                icon: AppIcons.token,
                tint: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: kHeroGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.brand(AppColors.primary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(AppIcons.token, color: Colors.white, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Text(s.coinCirculation,
                      style: AppTextStyles.h3.copyWith(color: Colors.white)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('${stats.coinsCirculating}',
                  style: AppTextStyles.display.copyWith(color: Colors.white)),
              Text(s.currentBalanceCoin,
                  style: AppTextStyles.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.85))),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  _MiniMetric(
                      label: s.earnedLabel, value: '${stats.coinsEarned}'),
                  const SizedBox(width: AppSpacing.xl),
                  _MiniMetric(
                      label: s.spentLabel, value: '${stats.coinsSpent}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _RoleBreakdown(stats: stats),
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(title: s.recentSignups),
        const SizedBox(height: AppSpacing.md),
        if (stats.recentUsers.isEmpty)
          EmptyState(
            title: s.noUsersYet,
            subtitle: s.signupsHere,
            icon: AppIcons.customers,
          )
        else
          for (final AdminUser u in stats.recentUsers) _RecentUserTile(u: u),
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(title: s.recentBusinesses),
        const SizedBox(height: AppSpacing.md),
        if (stats.recentCompanies.isEmpty)
          EmptyState(
            title: s.noBusinessesYet,
            subtitle: s.newBusinessesHere,
            icon: AppIcons.store,
          )
        else
          for (final AdminCompany c in stats.recentCompanies)
            _RecentCompanyTile(c: c),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(value,
            style: AppTextStyles.h2.copyWith(color: Colors.white)),
        Text(label,
            style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.8))),
      ],
    );
  }
}

class _RoleBreakdown extends ConsumerWidget {
  const _RoleBreakdown({required this.stats});

  final AdminStats stats;

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
      child: Row(
        children: <Widget>[
          _RolePill(label: s.roleCustomer, count: stats.customers),
          _RolePill(label: s.roleBusiness, count: stats.businessOwners),
          _RolePill(label: s.roleAdmin, count: stats.admins),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text('$count',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _RecentUserTile extends ConsumerWidget {
  const _RecentUserTile({required this.u});

  final AdminUser u;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
            Avatar(name: u.fullName.isEmpty ? u.email : u.fullName, size: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(u.fullName.isEmpty ? s.unnamed : u.fullName,
                      style: AppTextStyles.bodyLg),
                  Text(u.email, style: AppTextStyles.caption),
                ],
              ),
            ),
            AdminRoleBadge(role: u.role),
          ],
        ),
      ),
    );
  }
}

class _RecentCompanyTile extends StatelessWidget {
  const _RecentCompanyTile({required this.c});

  final AdminCompany c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(AppIcons.store,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(c.name, style: AppTextStyles.bodyLg),
                  Text(c.ownerEmail ?? c.category,
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            if (c.featured)
              const Icon(AppIcons.star, color: AppColors.warning, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Tappable content-management shortcut card on the admin dashboard.
class _MgmtCard extends StatelessWidget {
  const _MgmtCard({
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: tint.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: tint, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyLg
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: tint.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}
