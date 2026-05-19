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
  final TextEditingController _password =
      TextEditingController(text: 'password123');
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
    } catch (e, st) {
      if (!mounted) return;
      await _showError('Login failed', e, st);
      return;
    }
    if (!mounted) return;
    final UserRole effective =
        ref.read(currentUserProvider)?.role ?? widget.role;
    context.go(effective.landingPath);
  }

  Future<void> _showError(String title, Object e, StackTrace st) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(title),
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
  }

  Future<void> _forgotPassword(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Şifrəni unutmusan?'),
        content: const Text(
          'Şifrə bərpası üçün dəstəklə əlaqə saxla:\n\n'
          'hello@qazan.az\n+994 12 555 00 00\n\n'
          'Komandamız hesabını yoxlayıb şifrəni sıfırlayacaq.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Bağla'),
          ),
        ],
      ),
    );
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
                    onPressed: () => _forgotPassword(context),
                    child: const Text('Şifrəni unutmusan?'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: AppStrings.login,
                  loading: auth.isLoading,
                  onPressed: _submit,
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

