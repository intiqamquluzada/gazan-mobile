import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/auth_controller.dart';
import '../domain/user_role.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).signUp(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            role: widget.role,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          );
    } catch (e, st) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: const Text('Register failed'),
          content: SingleChildScrollView(
            child: SelectableText(
              '${e.runtimeType}: $e\n\n${st.toString().split('\n').take(10).join('\n')}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    final UserRole effective =
        ref.read(currentUserProvider)?.role ?? widget.role;
    context.go(effective == UserRole.business ? '/business' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Form(
            key: _form,
            child: ListView(
              children: <Widget>[
                Text(
                  widget.role == UserRole.business
                      ? 'Biznesini tanıt'
                      : 'Hesab yarat',
                  style: AppTextStyles.display,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.role == UserRole.business
                      ? 'Biznes profilin sənin üçün hazırlanır.'
                      : 'Bir neçə dəqiqədə qoşul və ilk möhürünü qazan.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                AppTextField(
                  label: widget.role == UserRole.business
                      ? 'Biznes adı'
                      : AppStrings.fullName,
                  controller: _name,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) =>
                      (v == null || v.trim().length < 2) ? 'Adı qeyd et' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: AppStrings.email,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.alternate_email_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) =>
                      (v == null || !v.contains('@')) ? 'Düzgün e-poçt daxil et' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: AppStrings.phone,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: AppStrings.password,
                  controller: _password,
                  obscure: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  validator: (String? v) =>
                      (v == null || v.length < 6) ? '6+ simvol olsun' : null,
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: 'Hesab yarat',
                  loading: auth.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text('Hesabın var?', style: AppTextStyles.bodySm),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(AppStrings.login),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
