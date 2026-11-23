import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/i18n/strings_panel2.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/money.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_program.dart';
import 'widgets/reward_catalog.dart';

class ManageProgramsScreen extends ConsumerWidget {
  const ManageProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<Company?> companyAsync = ref.watch(myCompanyProvider);
    final Company? company = companyAsync.value;
    if (company == null) {
      return Scaffold(
        body: companyAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : companyAsync.hasError
                ? ErrorState(
                    error: companyAsync.error!,
                    onRetry: () => ref.invalidate(myCompanyProvider),
                  )
                : const BusinessSetupPrompt(),
      );
    }
    final String businessId = company.id;
    final AsyncValue<List<LoyaltyProgram>> programs =
        ref.watch(programsForCompanyProvider(businessId));

    return Scaffold(
      appBar: AppBar(
        title: Text(s.loyaltyPrograms),
      ),
      body: programs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(programsForCompanyProvider(businessId)),
        ),
        data: (List<LoyaltyProgram> list) {
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(programsForCompanyProvider(businessId)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.huge,
              ),
              children: <Widget>[
                // ── Stamp / loyalty programs ──
                Text(s.stampPrograms, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                if (list.isEmpty)
                  EmptyState(
                    title: s.noProgramsYet,
                    subtitle: s.createFirstOffer,
                    icon: Icons.tune_outlined,
                    action: PrimaryButton(
                      label: s.newProgram,
                      icon: Icons.add_rounded,
                      expanded: false,
                      onPressed: () => _openProgramSheet(context, ref,
                          companyId: businessId),
                    ),
                  )
                else
                  for (final LoyaltyProgram p in list) ...<Widget>[
                    _ProgramTile(
                      program: p,
                      onEdit: () => _openProgramSheet(
                        context,
                        ref,
                        companyId: businessId,
                        existing: p,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.xl),

                // ── Coin reward catalog (moved here from "Mənim biznesim") ──
                RewardCatalog(companyId: businessId),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProgramSheet(context, ref, companyId: businessId),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.newProgram),
      ),
    );
  }

  Future<void> _openProgramSheet(
    BuildContext context,
    WidgetRef ref, {
    required String companyId,
    LoyaltyProgram? existing,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      // The sheet draws its own handle; the theme's would double it.
      showDragHandle: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (BuildContext _) =>
          ProgramFormSheet(companyId: companyId, existing: existing),
    );
  }
}

// ────────────────────────── Program tile ──────────────────────────

class _ProgramTile extends ConsumerWidget {
  const _ProgramTile({required this.program, required this.onEdit});

  final LoyaltyProgram program;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final Color tint = _tintFor(program.rewardType);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            leading: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(program.rewardType.icon, color: tint),
            ),
            title: Text(program.title, style: AppTextStyles.h3),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${program.stampsRequired} ${s.stampWord} → ${program.rewardLabelOf(s, currency: ref.watch(myCompanyProvider).valueOrNull?.currency)}',
                style: AppTextStyles.bodySm,
              ),
            ),
            trailing: Switch.adaptive(
              value: program.isActive,
              onChanged: (_) async {
                try {
                  await ref.read(loyaltyActionsProvider).toggleActive(program);
                } on ApiException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.message)));
                  }
                }
              },
            ),
          ),
          if (program.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(program.description, style: AppTextStyles.bodySm),
            ),
          const Divider(height: 1),
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(s.edit),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: AppColors.border,
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(context, ref, program),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.dangerText),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(s.delete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LoyaltyProgram p,
  ) async {
    final S s = ref.read(sProvider);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(s.deleteProgramTitle),
        content: Text('"${p.title}" ${s.willBeDeletedSuffix}'),
        actions: <Widget>[
          // Pop the dialog's own route, not the page underneath it.
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerText,
                backgroundBuilder: plainButtonFill,
                minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(loyaltyActionsProvider).deleteProgram(p);
    } on ApiException catch (e) {
      // e.g. customers still have gifts from this campaign to collect.
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Color _tintFor(LoyaltyRewardType type) => switch (type) {
        LoyaltyRewardType.freeItem => AppColors.action,
        LoyaltyRewardType.percentageDiscount => AppColors.catTeal,
        LoyaltyRewardType.fixedDiscount => AppColors.catCoffee,
        LoyaltyRewardType.cashback => AppColors.success,
      };
}

// ─────────────────────── Program form sheet ───────────────────────

class ProgramFormSheet extends ConsumerStatefulWidget {
  const ProgramFormSheet({
    super.key,
    required this.companyId,
    this.existing,
  });

  final String companyId;
  final LoyaltyProgram? existing;

  @override
  ConsumerState<ProgramFormSheet> createState() => _ProgramFormSheetState();
}

class _ProgramFormSheetState extends ConsumerState<ProgramFormSheet> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _rewardItem;
  late final TextEditingController _rewardValue;
  late int _stamps;
  late LoyaltyRewardType _rewardType;
  bool _saving = false;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    final LoyaltyProgram? p = widget.existing;
    _title = TextEditingController(text: p?.title ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _rewardItem = TextEditingController(
        text: p?.rewardItem ?? ref.read(sProvider).pDefaultRewardItem);
    _rewardValue =
        TextEditingController(text: p?.rewardValue?.toString() ?? '');
    _stamps = p?.stampsRequired ?? 5;
    _rewardType = p?.rewardType ?? LoyaltyRewardType.freeItem;
    _expiresAt = p?.expiresAt;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _rewardItem.dispose();
    _rewardValue.dispose();
    super.dispose();
  }

  bool get _needsValue => _rewardType != LoyaltyRewardType.freeItem;
  bool get _needsItem => _rewardType != LoyaltyRewardType.cashback;

  String _previewLabelOf(S s) {
    final num value = num.tryParse(_rewardValue.text) ?? 0;
    final String item = _rewardItem.text.trim().isEmpty
        ? s.productFallback
        : _rewardItem.text.trim();
    switch (_rewardType) {
      case LoyaltyRewardType.freeItem:
        return '1 ${s.freeWord} $item';
      case LoyaltyRewardType.percentageDiscount:
        return '$item ${s.onWord} ${_fmt(value)}% ${s.discountWord}';
      case LoyaltyRewardType.fixedDiscount:
        return '$item ${s.onWord} ${Money.format(value, _currency)} ${s.discountWord}';
      case LoyaltyRewardType.cashback:
        return '${Money.format(value, _currency)} ${s.pCashbackWord}';
    }
  }

  String? get _currency => ref.read(myCompanyProvider).valueOrNull?.currency;

  Future<void> _pickExpiry() async {
    final S s = ref.read(sProvider);
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
      cancelText: s.cancel,
      confirmText: s.selectAction,
    );
    if (picked != null) {
      setState(() => _expiresAt =
          DateTime(picked.year, picked.month, picked.day, 23, 59, 59));
    }
  }

  Widget _expiryTile(S s) {
    final DateTime? d = _expiresAt;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(s.programExpiry),
      subtitle: Text(d == null
          ? s.programNoExpiry
          : '${d.day.toString().padLeft(2, '0')}.'
              '${d.month.toString().padLeft(2, '0')}.${d.year}'),
      trailing: d == null
          ? null
          : IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(() => _expiresAt = null),
            ),
      onTap: _pickExpiry,
    );
  }

  String _fmt(num v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final num? value =
          _needsValue ? num.tryParse(_rewardValue.text.trim()) : null;
      final String item = _needsItem
          ? _rewardItem.text.trim()
          : ref.read(sProvider).productFallback;

      if (widget.existing == null) {
        await ref.read(loyaltyActionsProvider).createProgram(
              companyId: widget.companyId,
              title: _title.text.trim(),
              description: _description.text.trim(),
              stampsRequired: _stamps,
              rewardType: _rewardType,
              rewardValue: value,
              rewardItem: item,
              expiresAt: _expiresAt,
            );
      } else {
        await ref.read(loyaltyRepositoryProvider).updateProgram(
              widget.existing!.copyWith(
                title: _title.text.trim(),
                description: _description.text.trim(),
                stampsRequired: _stamps,
                rewardType: _rewardType,
                rewardValue: value,
                rewardItem: item,
                expiresAt: _expiresAt,
                clearExpiry: _expiresAt == null,
              ),
            );
        ref.invalidate(programsForCompanyProvider(widget.companyId));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existing == null
              ? ref.read(sProvider).programCreated
              : ref.read(sProvider).programUpdated),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final EdgeInsets bottom = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: bottom,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                widget.existing == null ? s.newLoyaltyProgram : s.editProgram,
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(s.threeSimpleSteps,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  )),
              const SizedBox(height: AppSpacing.lg),

              // Live preview — always on top so the owner sees exactly
              // what the customer's card will say as they build it.
              _expiryTile(s),
              const SizedBox(height: AppSpacing.md),
              _PreviewCard(
                title: _title.text.trim().isEmpty
                    ? s.newProgramPlaceholder
                    : _title.text.trim(),
                stamps: _stamps,
                rewardLabel: _previewLabelOf(s),
                rewardType: _rewardType,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Step 1 — reward type
              _StepHeader(n: 1, label: s.whatCustomerEarns),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final LoyaltyRewardType t in LoyaltyRewardType.values)
                    _RewardTypeChip(
                      type: t,
                      selected: _rewardType == t,
                      onTap: () => setState(() => _rewardType = t),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_needsValue)
                AppTextField(
                  label: _rewardType == LoyaltyRewardType.percentageDiscount
                      ? s.discountPercentLabel
                      : s.amountManatLabel,
                  hint: _rewardType == LoyaltyRewardType.percentageDiscount
                      ? s.egFifty
                      : s.egFive,
                  controller: _rewardValue,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon:
                      _rewardType == LoyaltyRewardType.percentageDiscount
                          ? Icons.percent_rounded
                          : Icons.payments_outlined,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  validator: (String? v) {
                    final num? n = num.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return s.validNumber;
                    if (_rewardType == LoyaltyRewardType.percentageDiscount &&
                        n > 100) {
                      return s.range0to100;
                    }
                    return null;
                  },
                ),
              if (_needsValue && _needsItem)
                const SizedBox(height: AppSpacing.md),
              if (_needsItem)
                AppTextField(
                  label: s.whichProduct,
                  hint: s.productExampleHint,
                  controller: _rewardItem,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  validator: (String? v) =>
                      (v == null || v.trim().isEmpty) ? s.enterProduct : null,
                ),
              const SizedBox(height: AppSpacing.xl),

              // Step 2 — stamps required
              _StepHeader(n: 2, label: s.howManyStamps),
              const SizedBox(height: AppSpacing.sm),
              _StampStepper(
                value: _stamps,
                onChanged: (int v) => setState(() => _stamps = v),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Step 3 — name + optional description
              _StepHeader(n: 3, label: s.nameYourProgram),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: s.programNameLabel,
                hint: s.programNameHint,
                controller: _title,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                validator: (String? v) =>
                    (v == null || v.trim().length < 3) ? s.enterName2 : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: s.descriptionOptional,
                hint: s.descriptionShortHint,
                controller: _description,
              ),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                label: widget.existing == null ? s.createAction : s.save,
                icon: Icons.check_rounded,
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(s.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Numbered step label ("① Müştəri nə qazanır?") used to break the
/// program form into three clear, guided steps.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.n, required this.label});

  final int n;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.action,
            shape: BoxShape.circle,
          ),
          child: Text('$n',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onDark,
                fontWeight: FontWeight.w800,
              )),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label,
            style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _RewardTypeChip extends ConsumerWidget {
  const _RewardTypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final LoyaltyRewardType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final Color bg =
        selected ? AppColors.action : Theme.of(context).colorScheme.surface;
    final Color fg = selected ? AppColors.onDark : AppColors.textPrimary;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.full),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? AppColors.action : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(type.icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(type.labelOf(s),
                style: AppTextStyles.bodySm.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

class _StampStepper extends ConsumerWidget {
  const _StampStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          Expanded(
            child: Center(
              child: Column(
                children: <Widget>[
                  Text('$value',
                      style: AppTextStyles.display.copyWith(fontSize: 28)),
                  Text(s.stampWord, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: value < 30 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends ConsumerWidget {
  const _PreviewCard({
    required this.title,
    required this.stamps,
    required this.rewardLabel,
    required this.rewardType,
  });

  final String title;
  final int stamps;
  final String rewardLabel;
  final LoyaltyRewardType rewardType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.action, AppColors.actionPressed],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.onDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(rewardType.icon, color: AppColors.onDark, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(s.previewWord,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onDark.withValues(alpha: 0.9),
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title,
              style: AppTextStyles.h3.copyWith(color: AppColors.onDark)),
          const SizedBox(height: 4),
          Text('$stamps ${s.stampWord} → $rewardLabel',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onDark.withValues(alpha: 0.9),
              )),
        ],
      ),
    );
  }
}
