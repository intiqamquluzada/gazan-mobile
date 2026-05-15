import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_program.dart';

class ManageProgramsScreen extends ConsumerWidget {
  const ManageProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Company?> companyAsync = ref.watch(myCompanyProvider);
    final Company? company = companyAsync.value;
    if (company == null) {
      return Scaffold(
        body: companyAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : const EmptyState(title: 'Biznes profili yoxdur'),
      );
    }
    final String businessId = company.id;
    final AsyncValue<List<LoyaltyProgram>> programs =
        ref.watch(programsForCompanyProvider(businessId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sadiqlik proqramları'),
      ),
      body: programs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: 'Xəta',
          subtitle: e.toString(),
          icon: Icons.error_outline_rounded,
        ),
        data: (List<LoyaltyProgram> list) {
          if (list.isEmpty) {
            return EmptyState(
              title: 'Hələ proqram yoxdur',
              subtitle: 'İlk təklifini yarat və müştəriləri qaytar.',
              icon: Icons.tune_outlined,
              action: PrimaryButton(
                label: 'Yeni proqram',
                icon: Icons.add_rounded,
                expanded: false,
                onPressed: () =>
                    _openProgramSheet(context, ref, companyId: businessId),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(programsForCompanyProvider(businessId)),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.huge,
              ),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext _, int i) => _ProgramTile(
                program: list[i],
                onEdit: () => _openProgramSheet(
                  context, ref,
                  companyId: businessId,
                  existing: list[i],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProgramSheet(context, ref, companyId: businessId),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni proqram'),
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
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.xs,
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
                '${program.stampsRequired} möhür → ${program.rewardLabel}',
                style: AppTextStyles.bodySm,
              ),
            ),
            trailing: Switch.adaptive(
              value: program.isActive,
              onChanged: (_) => ref
                  .read(loyaltyActionsProvider)
                  .toggleActive(program),
            ),
          ),
          if (program.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm,
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
                  label: const Text('Düzəliş et'),
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
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Sil'),
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
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext _) => AlertDialog(
        title: const Text('Proqramı silək?'),
        content: Text(
          '"${p.title}" silinəcək. Bu addım geri alına bilməz.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ləğv et'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(loyaltyActionsProvider).deleteProgram(p);
    }
  }

  Color _tintFor(LoyaltyRewardType type) => switch (type) {
        LoyaltyRewardType.freeItem => AppColors.primary,
        LoyaltyRewardType.percentageDiscount => AppColors.info,
        LoyaltyRewardType.fixedDiscount => AppColors.warning,
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

  @override
  void initState() {
    super.initState();
    final LoyaltyProgram? p = widget.existing;
    _title = TextEditingController(text: p?.title ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _rewardItem = TextEditingController(text: p?.rewardItem ?? 'qəhvə');
    _rewardValue =
        TextEditingController(text: p?.rewardValue?.toString() ?? '');
    _stamps = p?.stampsRequired ?? 5;
    _rewardType = p?.rewardType ?? LoyaltyRewardType.freeItem;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _rewardItem.dispose();
    _rewardValue.dispose();
    super.dispose();
  }

  bool get _needsValue =>
      _rewardType != LoyaltyRewardType.freeItem;
  bool get _needsItem =>
      _rewardType != LoyaltyRewardType.cashback;

  String get _previewLabel {
    final num value = num.tryParse(_rewardValue.text) ?? 0;
    final String item =
        _rewardItem.text.trim().isEmpty ? 'məhsul' : _rewardItem.text.trim();
    switch (_rewardType) {
      case LoyaltyRewardType.freeItem:
        return '1 pulsuz $item';
      case LoyaltyRewardType.percentageDiscount:
        return '$item üzrə ${_fmt(value)}% endirim';
      case LoyaltyRewardType.fixedDiscount:
        return '$item üzrə ${_fmt(value)} ₼ endirim';
      case LoyaltyRewardType.cashback:
        return '${_fmt(value)} ₼ cashback';
    }
  }

  String _fmt(num v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final num? value = _needsValue
          ? num.tryParse(_rewardValue.text.trim())
          : null;
      final String item = _needsItem ? _rewardItem.text.trim() : 'məhsul';

      if (widget.existing == null) {
        await ref.read(loyaltyActionsProvider).createProgram(
              companyId: widget.companyId,
              title: _title.text.trim(),
              description: _description.text.trim(),
              stampsRequired: _stamps,
              rewardType: _rewardType,
              rewardValue: value,
              rewardItem: item,
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
              ),
            );
        ref.invalidate(programsForCompanyProvider(widget.companyId));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existing == null
              ? 'Proqram yaradıldı'
              : 'Proqram yeniləndi'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets bottom = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: bottom,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl,
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
                widget.existing == null
                    ? 'Yeni sadiqlik proqramı'
                    : 'Proqramı düzəliş et',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Müştərinin nə qazanacağını sən özün təyin et.',
                  style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.xl),

              // Title
              AppTextField(
                label: 'Proqram adı',
                hint: 'Məs: 5 al, 6-cı pulsuz',
                controller: _title,
                textInputAction: TextInputAction.next,
                validator: (String? v) =>
                    (v == null || v.trim().length < 3) ? 'Adı yaz' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Reward type
              Text('Mükafat növü',
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
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
              const SizedBox(height: AppSpacing.lg),

              // Reward value (% or AZN) — only when needed
              if (_needsValue) ...<Widget>[
                AppTextField(
                  label: _rewardType == LoyaltyRewardType.percentageDiscount
                      ? 'Endirim faizi (%)'
                      : 'Məbləğ (₼)',
                  hint: _rewardType == LoyaltyRewardType.percentageDiscount
                      ? 'Məs: 50'
                      : 'Məs: 5',
                  controller: _rewardValue,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: _rewardType ==
                          LoyaltyRewardType.percentageDiscount
                      ? Icons.percent_rounded
                      : Icons.payments_outlined,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  validator: (String? v) {
                    final num? n = num.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return 'Düzgün rəqəm daxil et';
                    if (_rewardType ==
                            LoyaltyRewardType.percentageDiscount &&
                        n > 100) {
                      return '0–100 arası olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Reward item
              if (_needsItem) ...<Widget>[
                AppTextField(
                  label: 'Hansı məhsul üçündür?',
                  hint: 'Məs: qəhvə, burger, manikür',
                  controller: _rewardItem,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  validator: (String? v) =>
                      (v == null || v.trim().isEmpty) ? 'Məhsulu yaz' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Stamps required
              Text('Tələb olunan möhür sayı',
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: AppSpacing.sm),
              _StampStepper(
                value: _stamps,
                onChanged: (int v) => setState(() => _stamps = v),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description
              AppTextField(
                label: 'Açıqlama (istəyə bağlı)',
                hint: 'Müştərinin görəcəyi qısa təsvir',
                controller: _description,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Live preview
              _PreviewCard(
                title: _title.text.trim().isEmpty
                    ? 'Yeni proqram'
                    : _title.text.trim(),
                stamps: _stamps,
                rewardLabel: _previewLabel,
                rewardType: _rewardType,
              ),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                label: widget.existing == null ? 'Yarat' : 'Yadda saxla',
                icon: Icons.check_rounded,
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ləğv et'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardTypeChip extends StatelessWidget {
  const _RewardTypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final LoyaltyRewardType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg =
        selected ? AppColors.primary : Theme.of(context).colorScheme.surface;
    final Color fg = selected ? Colors.white : AppColors.textPrimary;
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
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(type.icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(type.label,
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

class _StampStepper extends StatelessWidget {
  const _StampStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
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
                  Text('$value', style: AppTextStyles.display.copyWith(fontSize: 28)),
                  Text('möhür', style: AppTextStyles.caption),
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

class _PreviewCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, AppColors.primaryDark],
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(rewardType.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Önbaxış',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.h3.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('$stamps möhür → $rewardLabel',
              style: AppTextStyles.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              )),
        ],
      ),
    );
  }
}
