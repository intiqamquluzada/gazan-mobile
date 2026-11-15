import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/brand_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/auth_remote_data_source.dart';

/// Two-step password reset: ask for the account email, then verify the
/// 6-digit code the backend emails and choose a new password.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

enum _Step { email, code }

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  _Step _step = _Step.email;
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) _email.text = widget.initialEmail!;
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _sendCode() async {
    if (_step == _Step.email) {
      if (!_form.currentState!.validate()) return;
    } else if (!_email.text.contains('@')) {
      // Resending from the code step: the code/password fields may still
      // be empty, so only the address matters here.
      _toast(ref.read(sProvider).invalidEmail);
      return;
    }
    setState(() => _loading = true);
    try {
      await ref
          .read(authRemoteDataSourceProvider)
          .requestPasswordReset(_email.text);
      if (!mounted) return;
      setState(() => _step = _Step.code);
      _toast(ref.read(sProvider).codeSentToEmail);
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast(ref.read(sProvider).errorTryAgain);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRemoteDataSourceProvider).confirmPasswordReset(
            email: _email.text,
            code: _code.text,
            newPassword: _password.text,
          );
      if (!mounted) return;
      final S s = ref.read(sProvider);
      await showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: Text(s.passwordUpdated),
          content: Text(s.newPasswordReady),
          actions: <Widget>[
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(s.login),
            ),
          ],
        ),
      );
      if (!mounted) return;
      context.canPop() ? context.pop() : context.go('/login');
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast(ref.read(sProvider).errorTryAgain);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final bool onEmail = _step == _Step.email;
    return Scaffold(
      appBar: AppBar(leadingWidth: 72, leading: const CircleBackButton()),
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
                Center(
                  child: Image.asset(
                    'assets/illustrations/forgot_mail.png',
                    width: 150,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  s.resetPassword,
                  style: AppTextStyles.h1.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  onEmail
                      ? s.resetPasswordEmailPrompt
                      : '${_email.text} ${s.codeSentPrompt}',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                if (onEmail) ...<Widget>[
                  AppTextField(
                    label: s.email,
                    hint: s.emailHint,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.alternate_email_rounded,
                    textInputAction: TextInputAction.done,
                    validator: (String? v) =>
                        (v == null || !v.contains('@')) ? s.invalidEmail : null,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: s.sendCode,
                    trailingIcon: Icons.arrow_forward_rounded,
                    loading: _loading,
                    onPressed: _loading ? null : _sendCode,
                  ),
                ] else ...<Widget>[
                  AppTextField(
                    label: s.confirmationCode,
                    hint: s.sixDigits,
                    controller: _code,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.pin_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (String? v) =>
                        (v == null || v.trim().length != 6)
                            ? s.enterSixDigitCode
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: s.newPassword,
                    hint: s.eightPlusChars,
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
                        (v == null || v.length < 8) ? s.min8Chars : null,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: s.updatePasswordAction,
                    trailingIcon: Icons.arrow_forward_rounded,
                    loading: _loading,
                    onPressed: _loading ? null : _resetPassword,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _loading ? null : _sendCode,
                    child: Text(s.resendCode),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
