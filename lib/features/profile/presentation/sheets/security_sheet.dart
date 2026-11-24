import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/domain/app_user.dart';
import '../../data/profile_remote_data_source.dart';
import '_sheet_handle.dart';

class SecuritySheet extends ConsumerStatefulWidget {
  const SecuritySheet({super.key});

  @override
  ConsumerState<SecuritySheet> createState() => _SecuritySheetState();
}

class _SecuritySheetState extends ConsumerState<SecuritySheet> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final bool hasPassword = ref.read(currentUserProvider)?.hasPassword ?? true;
    try {
      final Map<String, dynamic>? session =
          await ref.read(profileRemoteDataSourceProvider).changePassword(
                currentPassword: hasPassword ? _current.text : null,
                newPassword: _new.text,
              );
      // Every other device was signed out; keep this one signed in.
      if (session != null) {
        await ref.read(authControllerProvider.notifier).adoptSession(session);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(sProvider).passwordUpdated)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(errorText(ref.read(sProvider), e,
                fallback: ref.read(sProvider).error))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AppUser? user = ref.watch(currentUserProvider);
    final bool hasPassword = user?.hasPassword ?? true;
    final EdgeInsets bottom = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: bottom,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SheetHandle(),
              const SizedBox(height: AppSpacing.lg),
              Text(hasPassword ? s.changePassword : s.setPassword,
                  style: AppTextStyles.h2),
              if (!hasPassword) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(s.setPasswordHint, style: AppTextStyles.bodySm),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (hasPassword) ...<Widget>[
                AppTextField(
                  hint: s.hintCurrentPassword,
                  label: s.currentPassword,
                  controller: _current,
                  obscure: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (String? v) =>
                      (v == null || v.isEmpty) ? s.enter : null,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                hint: s.passwordHintMin8,
                label: s.newPassword,
                controller: _new,
                obscure: true,
                prefixIcon: Icons.lock_reset_rounded,
                validator: (String? v) =>
                    (v == null || v.length < 8) ? s.min8Chars : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                hint: s.hintRepeatPassword,
                label: s.repeatNewPassword,
                controller: _confirm,
                obscure: true,
                prefixIcon: Icons.lock_reset_rounded,
                validator: (String? v) =>
                    v != _new.text ? s.passwordsDontMatch : null,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: s.save,
                icon: Icons.check_rounded,
                loading: _saving,
                onPressed: _saving ? null : _save,
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
