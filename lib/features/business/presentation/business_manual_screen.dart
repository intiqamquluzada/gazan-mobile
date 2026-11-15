import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/phone_util.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/phone_field.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/user_role.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_program.dart';
import '../application/business_providers.dart';
import '../application/panel_providers.dart';
import '../domain/panel_models.dart';

/// Fallback for when a tap is impossible (no NFC on the customer's phone, a
/// damaged card): find the customer by number, then add a stamp or coins.
class BusinessManualScreen extends ConsumerStatefulWidget {
  const BusinessManualScreen({super.key});

  @override
  ConsumerState<BusinessManualScreen> createState() => _ManualState();
}

class _ManualState extends ConsumerState<BusinessManualScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _amount = TextEditingController(text: '100');
  String _dial = '+994';
  CustomerLookup? _customer;
  bool _notFound = false;
  bool _busy = false;
  bool _stamp = true;
  int _stamps = 1;
  LoyaltyProgram? _program;

  @override
  void dispose() {
    _phone.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _toast(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  Future<void> _lookup() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _customer = null;
      _notFound = false;
    });
    try {
      final CustomerLookup? c = await ref
          .read(panelRepositoryProvider)
          .lookup(PhoneUtil.normalize(_phone.text, _dial));
      if (mounted) {
        setState(() {
          _customer = c;
          _notFound = c == null;
        });
      }
    } on ApiException catch (e) {
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit(String companyId) async {
    final CustomerLookup? c = _customer;
    if (c == null) return;
    final S s = ref.read(sProvider);
    final int? amount = int.tryParse(_amount.text.trim());
    if (_stamp && _program == null) {
      _toast(s.manualPickProgram);
      return;
    }
    if (!_stamp && (amount == null || amount <= 0 || amount > 10000)) {
      _toast(s.manualBadAmount);
      return;
    }
    setState(() => _busy = true);
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    try {
      if (_stamp) {
        await container.read(panelRepositoryProvider).addStamp(
              customerId: c.userId,
              programId: _program!.id,
              stamps: _stamps,
            );
      } else {
        await container.read(panelRepositoryProvider).grantCoins(
              customerId: c.userId,
              companyId: companyId,
              amount: amount!,
            );
      }
      container
        ..invalidate(myBusinessStatsProvider)
        ..invalidate(myCustomersProvider);
      _toast('${c.fullName} · ${s.manualDone}');
      if (mounted) {
        setState(() {
          _customer = null;
          _phone.clear();
          // The next customer starts from a clean form.
          _stamps = 1;
          _program = null;
        });
      }
    } on ApiException catch (e) {
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AppUser? user = ref.watch(currentUserProvider);
    final bool cashier = user?.role == UserRole.cashier;
    final AsyncValue<Company?>? companyAsync =
        cashier ? null : ref.watch(myCompanyProvider);
    final String? companyId =
        cashier ? user?.staffCompanyId : companyAsync?.valueOrNull?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.manualTitle),
        actions: <Widget>[
          if (cashier)
            IconButton(
              tooltip: s.account,
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () => context.push('/business/account'),
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: <Widget>[
            Text(s.manualHint, style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.lg),
            PhoneField(
              controller: _phone,
              onDialChanged: (String v) => _dial = v,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _lookup(),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _busy ? null : _lookup,
              icon: const Icon(Icons.search_rounded),
              label: Text(s.manualFind),
            ),
            if (_notFound)
              EmptyState(
                title: s.manualNotFound,
                icon: Icons.person_off_outlined,
              ),
            if (_customer != null && companyId != null)
              _customerPanel(s, _customer!, companyId)
            else if (_customer != null &&
                (companyAsync?.isLoading ?? false))
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_customer != null)
              EmptyState(
                title: companyAsync?.hasError ?? false
                    ? s.notLoaded
                    : s.noBusinessProfile,
                icon: Icons.storefront_outlined,
                action: companyAsync == null
                    ? null
                    : OutlinedButton(
                        onPressed: () => ref.invalidate(myCompanyProvider),
                        child: Text(s.retry),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _customerPanel(S s, CustomerLookup c, String companyId) {
    final List<LoyaltyProgram> programs = (ref
                .watch(programsForCompanyProvider(companyId))
                .valueOrNull ??
            const <LoyaltyProgram>[])
        .where((LoyaltyProgram p) => p.isOpen)
        .toList();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(c.fullName, style: AppTextStyles.h2),
          if (c.phone != null) Text(c.phone!, style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.lg),
          SegmentedButton<bool>(
            segments: <ButtonSegment<bool>>[
              ButtonSegment<bool>(value: true, label: Text(s.nfcKindStamp)),
              ButtonSegment<bool>(value: false, label: Text(s.coinLabel)),
            ],
            selected: <bool>{_stamp},
            onSelectionChanged: (Set<bool> v) =>
                setState(() => _stamp = v.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_stamp) ...<Widget>[
            DropdownButtonFormField<LoyaltyProgram>(
              initialValue: programs.contains(_program) ? _program : null,
              decoration: InputDecoration(labelText: s.campaigns),
              items: <DropdownMenuItem<LoyaltyProgram>>[
                for (final LoyaltyProgram p in programs)
                  DropdownMenuItem<LoyaltyProgram>(
                      value: p, child: Text(p.title)),
              ],
              onChanged: (LoyaltyProgram? p) => setState(() => _program = p),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                IconButton(
                  onPressed:
                      _stamps > 1 ? () => setState(() => _stamps--) : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                Text('$_stamps ${s.stampWord}', style: AppTextStyles.h3),
                IconButton(
                  onPressed:
                      _stamps < 10 ? () => setState(() => _stamps++) : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
          ] else
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: s.coinLabel),
            ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _busy ? null : () => _submit(companyId),
            child: Text(s.manualAdd),
          ),
        ],
      ),
    );
  }
}
