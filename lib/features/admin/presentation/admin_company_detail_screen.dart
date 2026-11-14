import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'admin_widgets.dart';

/// One venue from the platform's side: its numbers and approve/suspend.
class AdminCompanyDetailScreen extends ConsumerWidget {
  const AdminCompanyDetailScreen({super.key, required this.companyId});

  final String companyId;

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    String status, {
    bool askReason = false,
  }) async {
    final S s = ref.read(sProvider);
    String? reason;
    if (askReason) {
      final TextEditingController c = TextEditingController();
      final bool? ok = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: Text(s.companySuspend),
          content: TextField(
            controller: c,
            decoration: InputDecoration(labelText: s.reasonLabel),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(s.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(s.companySuspend),
            ),
          ],
        ),
      );
      reason = c.text.trim();
      c.dispose();
      if (ok != true) return;
    }
    if (!context.mounted) return;
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await container
          .read(adminRepositoryProvider)
          .setCompanyStatus(companyId, status, reason: reason);
      container
        ..invalidate(adminCompanyDetailProvider(companyId))
        ..invalidate(adminStatsProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<AdminCompanyDetail> data =
        ref.watch(adminCompanyDetailProvider(companyId));
    return Scaffold(
      appBar: AppBar(title: Text(s.companyDetailTitle)),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(title: s.notLoaded, subtitle: '$e'),
        data: (AdminCompanyDetail c) => ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(c.name, style: AppTextStyles.h1)),
                CompanyStatusBadge(status: c.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(c.ownerEmail ?? '—', style: AppTextStyles.bodySm),
            if (c.address != null) Text(c.address!, style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                _Metric(s.anActiveCustomers, c.customers),
                _Metric(s.nfcCards, c.tags),
                _Metric(s.anCoinsEarned, c.coinsEarned),
                _Metric(s.anCoinsSpent, c.coinsSpent),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (c.status != 'APPROVED')
              FilledButton.icon(
                onPressed: () => _setStatus(context, ref, 'APPROVED'),
                icon: const Icon(Icons.check_rounded),
                label: Text(s.companyApprove),
              ),
            if (c.status != 'SUSPENDED') ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerText),
                onPressed: () => _setStatus(context, ref, 'SUSPENDED',
                    askReason: true),
                icon: const Icon(Icons.block_rounded),
                label: Text(s.companySuspend),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('$value', style: AppTextStyles.h2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
