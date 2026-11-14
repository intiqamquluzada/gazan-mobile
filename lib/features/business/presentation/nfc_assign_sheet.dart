import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../companies/application/companies_providers.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_program.dart';
import '../../nfc/data/nfc_admin_repository.dart';

/// Decides what a physical card does when a customer's phone touches it:
/// stamp a campaign, give coins, give a gift, or open the cashier window.
Future<void> showNfcAssignSheet(BuildContext context, NfcCard card) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AssignSheet(card: card),
  );
}

class _AssignSheet extends ConsumerStatefulWidget {
  const _AssignSheet({required this.card});

  final NfcCard card;

  @override
  ConsumerState<_AssignSheet> createState() => _AssignSheetState();
}

class _AssignSheetState extends ConsumerState<_AssignSheet> {
  late String _kind =
      widget.card.kind == 'UNASSIGNED' ? 'STAMP' : widget.card.kind;
  late String? _programId = widget.card.programId;
  late final TextEditingController _label =
      TextEditingController(text: widget.card.label ?? '');
  late final TextEditingController _points =
      TextEditingController(text: '${widget.card.pointsValue}');
  late final TextEditingController _stamps =
      TextEditingController(text: '${widget.card.stampsValue}');
  late final TextEditingController _cooldown =
      TextEditingController(text: '${widget.card.cooldownSec}');
  late final TextEditingController _cap =
      TextEditingController(text: '${widget.card.dailyCapPerUser}');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _label.dispose();
    _points.dispose();
    _stamps.dispose();
    _cooldown.dispose();
    _cap.dispose();
    super.dispose();
  }

  bool _inRange(String text, int min, int max) {
    final int? v = int.tryParse(text.trim());
    return v != null && v >= min && v <= max;
  }

  String? _validate(S s) {
    if (_kind == 'STAMP' && _programId == null) return s.manualPickProgram;
    if (_kind == 'POINTS' && !_inRange(_points.text, 1, 100000)) {
      return s.manualBadAmount;
    }
    if (_kind == 'STAMP' && !_inRange(_stamps.text, 1, 10)) {
      return s.manualBadAmount;
    }
    if (_kind != 'SPEND' &&
        (!_inRange(_cooldown.text, 0, 86400) ||
            !_inRange(_cap.text, 1, 100))) {
      return s.manualBadAmount;
    }
    return null;
  }

  Future<void> _save() async {
    final S s = ref.read(sProvider);
    final String? invalid = _validate(s);
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    try {
      await container.read(nfcAdminRepositoryProvider).assign(
            widget.card.id,
            kind: _kind,
            programId: _kind == 'STAMP' ? _programId : null,
            pointsValue:
                _kind == 'POINTS' ? int.parse(_points.text.trim()) : null,
            stampsValue:
                _kind == 'STAMP' ? int.parse(_stamps.text.trim()) : null,
            label: _label.text.trim().isEmpty ? null : _label.text.trim(),
            cooldownSec:
                _kind == 'SPEND' ? null : int.parse(_cooldown.text.trim()),
            dailyCapPerUser:
                _kind == 'SPEND' ? null : int.parse(_cap.text.trim()),
          );
      container.invalidate(myNfcCardsProvider);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final String companyId = widget.card.companyId.isNotEmpty
        ? widget.card.companyId
        : (ref.watch(myCompanyProvider).valueOrNull?.id ?? '');
    final List<LoyaltyProgram> programs = companyId.isEmpty
        ? const <LoyaltyProgram>[]
        : (ref.watch(programsForCompanyProvider(companyId)).valueOrNull ??
                const <LoyaltyProgram>[])
            .where((LoyaltyProgram p) => p.isOpen)
            .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(s.nfcAssignTitle, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: <ButtonSegment<String>>[
                for (final String k in const <String>[
                  'STAMP',
                  'POINTS',
                  'SPEND',
                ])
                  ButtonSegment<String>(
                      value: k, label: Text(nfcKindLabel(s, k))),
              ],
              selected: <String>{_kind},
              onSelectionChanged: (Set<String> v) => setState(() {
                _kind = v.first;
                _error = null;
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(_explanation(s), style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.lg),
            if (_kind == 'STAMP') ...<Widget>[
              DropdownButtonFormField<String>(
                initialValue: programs.any(
                        (LoyaltyProgram p) => p.id == _programId)
                    ? _programId
                    : null,
                decoration: InputDecoration(labelText: s.campaigns),
                items: <DropdownMenuItem<String>>[
                  for (final LoyaltyProgram p in programs)
                    DropdownMenuItem<String>(value: p.id, child: Text(p.title)),
                ],
                onChanged: (String? v) => setState(() => _programId = v),
              ),
              const SizedBox(height: AppSpacing.sm),
              _number(_stamps, s.nfcStampsPerTap),
            ],
            if (_kind == 'POINTS') _number(_points, s.nfcPointsPerTap),
            if (_kind != 'SPEND') ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              _number(_cooldown, s.nfcCooldown, helper: s.nfcCooldownHelp),
              const SizedBox(height: AppSpacing.sm),
              _number(_cap, s.nfcDailyCap),
            ],
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _label,
              decoration: InputDecoration(labelText: s.name),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: AppTextStyles.bodySm),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(s.saveShort),
            ),
          ],
        ),
      ),
    );
  }

  String _explanation(S s) => switch (_kind) {
        'STAMP' => s.nfcExplainStamp,
        'POINTS' => s.nfcExplainPoints,
        _ => s.nfcExplainSpend,
      };

  Widget _number(TextEditingController c, String label, {String? helper}) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, helperText: helper),
    );
  }
}
