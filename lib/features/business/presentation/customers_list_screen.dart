import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/i18n/strings_panel2.dart';
import '../../../core/widgets/periodic_refresh.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/business_providers.dart';
import '../domain/customer_summary.dart';

class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() =>
      _CustomersListScreenState();
}

class _CustomersListScreenState extends ConsumerState<CustomersListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<CustomerSummary>> customers =
        ref.watch(myCustomersProvider);

    // Customers keep earning while this screen is open.
    return PeriodicRefresh(
      onTick: () => ref.invalidate(myCustomersProvider),
      child: Scaffold(
      appBar: AppBar(title: Text(s.tabCustomers)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: TextField(
              onChanged: (String v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: s.searchCustomer,
                prefixIcon: const Icon(AppIcons.search),
              ),
            ),
          ),
          Expanded(
            child: customers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, _) => EmptyState(
                title: s.error,
                subtitle: e.toString(),
                icon: AppIcons.error,
              ),
              data: (List<CustomerSummary> all) {
                final List<CustomerSummary> filtered = _query.trim().isEmpty
                    ? all
                    : all
                        .where((CustomerSummary c) => c.fullName
                            .toLowerCase()
                            .contains(_query.toLowerCase()))
                        .toList();
                if (filtered.isEmpty) {
                  return EmptyState(
                    title: s.nothingFound,
                    icon: AppIcons.searchOff,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.huge,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (BuildContext _, int i) => _Row(c: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.c});

  final CustomerSummary c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return InkWell(
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
            Avatar(name: c.nameOr(s.pCustomerFallback), size: 44),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(c.nameOr(s.pCustomerFallback),
                      style: AppTextStyles.bodyLg),
                  Text(
                    '${c.totalVisits} ${s.visitsWord} · ${s.lastVisit} ${AppFormat.dateTime(c.lastVisitAt)}',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _Pill(
                    value: '${c.totalStamps}',
                    label: s.stampWord,
                    tint: AppColors.action),
                const SizedBox(height: 4),
                _Pill(
                    value: '${c.rewardsClaimed}',
                    label: s.rewardWord,
                    tint: AppColors.success),
                if (c.coinBalance > 0) ...<Widget>[
                  const SizedBox(height: 4),
                  _Pill(
                      value: '${c.coinBalance}',
                      label: s.coinLabel,
                      tint: AppColors.reward),
                ],
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.value, required this.label, required this.tint});

  final String value;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(value,
              style: AppTextStyles.caption.copyWith(
                color: tint,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: tint)),
        ],
      ),
    );
  }
}
