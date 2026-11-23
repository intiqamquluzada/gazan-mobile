import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/phone_util.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/phone_field.dart';
import '../application/panel_providers.dart';
import '../domain/panel_models.dart';

/// Owner → cashier accounts. A cashier sees only the till and manual entry.
class BusinessStaffScreen extends ConsumerWidget {
  const BusinessStaffScreen({super.key});

  Future<void> _remove(
      BuildContext context, WidgetRef ref, StaffMember m) async {
    final S s = ref.read(sProvider);
    final bool ok = await showConfirmSheet(
      context,
      title: s.staffRemoveTitle,
      body: m.fullName,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      icon: Icons.person_remove_outlined,
    );
    if (!ok || !context.mounted) return;
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await container.read(panelRepositoryProvider).removeStaff(m.id);
      container.invalidate(staffProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<StaffMember>> staff = ref.watch(staffProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.staffTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => const _AddStaffSheet(),
        ),
        icon: const Icon(Icons.person_add_alt_rounded),
        label: Text(s.staffAdd),
      ),
      body: staff.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(staffProvider)),
        data: (List<StaffMember> list) {
          final List<StaffMember> active =
              list.where((StaffMember m) => m.active).toList();
          if (active.isEmpty) {
            return EmptyState(
              title: s.staffEmpty,
              subtitle: s.staffEmptyHint,
              icon: Icons.badge_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: active.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, int i) {
              final StaffMember m = active[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Avatar(name: m.fullName, size: 42),
                title: Text(m.fullName, style: AppTextStyles.bodyLg),
                subtitle: Text(m.phone ?? m.email),
                trailing: IconButton(
                  tooltip: s.delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _remove(context, ref, m),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddStaffSheet extends ConsumerStatefulWidget {
  const _AddStaffSheet();

  @override
  ConsumerState<_AddStaffSheet> createState() => _AddStaffSheetState();
}

class _AddStaffSheetState extends ConsumerState<_AddStaffSheet> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String _dial = '+994';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    try {
      await container.read(panelRepositoryProvider).addStaff(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            phone: PhoneUtil.normalize(_phone.text, _dial),
            password: _password.text,
          );
      container.invalidate(staffProvider);
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
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(s.staffAdd, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(hintText: s.fullNameHint, labelText: s.fullName),
                validator: (String? v) => (v == null || v.trim().length < 2)
                    ? s.enterNameShort
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: s.emailHint, labelText: s.email),
                validator: (String? v) =>
                    (v == null || !v.contains('@')) ? s.invalidEmail : null,
              ),
              const SizedBox(height: AppSpacing.md),
              PhoneField(
                controller: _phone,
                onDialChanged: (String v) => _dial = v,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(hintText: s.passwordHintMin8, labelText: s.password),
                validator: (String? v) =>
                    (v == null || v.length < 8) ? s.pwErrMin8 : null,
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
      ),
    );
  }
}
