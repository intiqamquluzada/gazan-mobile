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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController(
    text: 'demo@qazan.az',
  );
  final TextEditingController _password = TextEditingController(text: '••••••');
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).signIn(
            email: _email.text.trim(),
            password: _password.text,
            role: widget.role,
          );
    } catch (_) {
      if (!mounted) return;
      final String msg =
          ref.read(authControllerProvider).error ?? 'Daxil olmaq alınmadı';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
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
                Text('Xoş gəldin 👋', style: AppTextStyles.display),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.role == UserRole.business
                      ? 'Biznes hesabına daxil ol və müştərilərini izlə.'
                      : 'Hesabına daxil ol və sevimli yerlərindən qazan.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                AppTextField(
                  label: AppStrings.email,
                  hint: 'sən@qazan.az',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.alternate_email_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) =>
                      (v == null || !v.contains('@')) ? 'Düzgün e-poçt daxil et' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: AppStrings.password,
                  controller: _password,
                  obscure: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  suffix: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (String? v) =>
                      (v == null || v.length < 4) ? 'Şifrə qısadır' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Şifrəni unutmusan?'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: AppStrings.login,
                  loading: auth.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.xl),
                _OrDivider(label: AppStrings.orContinueWith),
                const SizedBox(height: AppSpacing.lg),
                _SocialButton(
                  icon: Icons.apple,
                  label: 'Apple ilə davam et',
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                _SocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Google ilə davam et',
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text('Hesabın yoxdur?',
                          style: AppTextStyles.bodySm),
                      TextButton(
                        onPressed: () => context.push(
                          '/register?role=${widget.role.name}',
                        ),
                        child: const Text(AppStrings.register),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label, style: AppTextStyles.caption),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
