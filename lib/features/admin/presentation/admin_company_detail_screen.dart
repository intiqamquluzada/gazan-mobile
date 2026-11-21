import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/i18n/strings_panel2.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../companies/domain/business_category.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'admin_widgets.dart';

/// One venue from the platform's side: its numbers and approve/suspend.
class AdminCompanyDetailScreen extends ConsumerStatefulWidget {
  const AdminCompanyDetailScreen({super.key, required this.companyId});

  final String companyId;

  @override
  ConsumerState<AdminCompanyDetailScreen> createState() =>
      _AdminCompanyDetailScreenState();
}

class _AdminCompanyDetailScreenState
    extends ConsumerState<AdminCompanyDetailScreen> {
  /// Blocks double taps while a status change is in flight.
  bool _busy = false;

  String get companyId => widget.companyId;

  Future<String?> _askReason(S s) async {
    final TextEditingController c = TextEditingController();
    try {
      final bool? ok = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: Text(s.companySuspend),
          content: TextField(
            controller: c,
            maxLength: 300,
            maxLines: 3,
            minLines: 1,
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
      return ok == true ? c.text.trim() : null;
    } finally {
      // The dialog's exit animation still reads the controller; dispose it
      // only after that finishes.
      Future<void>.delayed(const Duration(milliseconds: 400), c.dispose);
    }
  }

  Future<void> _setStatus(String status, {bool askReason = false}) async {
    if (_busy) return;
    final S s = ref.read(sProvider);
    String? reason;
    if (askReason) {
      reason = await _askReason(s);
      if (reason == null) return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adminRepositoryProvider)
          .setCompanyStatus(companyId, status, reason: reason);
      ref
        ..invalidate(adminCompanyDetailProvider(companyId))
        ..invalidate(adminStatsProvider)
        ..invalidate(adminCompanyOptionsProvider);
      messenger.showSnackBar(SnackBar(
        content: Text(status == 'APPROVED'
            ? s.pCompanyApprovedDone
            : s.pCompanySuspendedDone),
      ));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${s.failed}: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(text, style: AppTextStyles.bodySm)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
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
            if (c.tagline != null && c.tagline!.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(c.tagline!,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: AppSpacing.sm),
            if (c.category != null)
              _info(Icons.category_outlined,
                  BusinessCategory.fromJson(c.category!).labelOf(s)),
            _info(
                Icons.person_outline_rounded,
                <String>[
                  if (c.ownerName != null && c.ownerName!.isNotEmpty)
                    c.ownerName!,
                  c.ownerEmail ?? '—',
                ].join(' · ')),
            if (c.phone != null && c.phone!.isNotEmpty)
              _info(Icons.phone_outlined, c.phone!),
            if (c.address != null && c.address!.isNotEmpty)
              _info(Icons.place_outlined, c.address!),
            if (c.createdAt != null)
              _info(Icons.event_outlined, _day(c.createdAt!)),
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
                onPressed: _busy ? null : () => _setStatus('APPROVED'),
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_rounded),
                label: Text(s.companyApprove),
              ),
            if (c.status != 'SUSPENDED') ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerText),
                onPressed: _busy
                    ? null
                    : () => _setStatus('SUSPENDED', askReason: true),
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

String _day(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
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
