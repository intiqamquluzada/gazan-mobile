import '../../../core/legal/legal_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/platform/app_variant.dart';
import '../../../core/utils/phone_util.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/qazan_logo.dart';
import '../application/auth_controller.dart';
import '../domain/user_role.dart';
import 'social_buttons.dart';

/// Single sign-in page for every role — the account itself decides whether
/// the user lands in the customer, business or admin shell.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialIdentifier});

  /// Pre-filled when sign-up finds the number is already registered.
  final String? initialIdentifier;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _email =
      TextEditingController(text: widget.initialIdentifier ?? '');
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// An email goes as typed; a phone becomes `+` and digits. A number
  /// without a country code is read in the device's own country.
  String _identifier() {
    final String raw = _email.text.trim();
    return raw.contains('@')
        ? raw
        : PhoneUtil.normalize(raw, defaultDialCode(ref));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).signIn(
            identifier: _identifier(),
            password: _password.text,
          );
    } catch (_) {
      if (!mounted) return;
      final String msg = ref.read(authControllerProvider).error ??
          ref.read(sProvider).loginFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }
    if (!mounted) return;
    final UserRole effective =
        ref.read(currentUserProvider)?.role ?? UserRole.customer;
    context.go(effective.landingPath);
  }

  void _forgotPassword(BuildContext context) {
    // Carry whatever the user already typed into the email field so the
    // reset screen can pre-fill it.
    final String typed = _email.text.trim();
    final String email = typed.contains('@') ? typed : '';
    context.push(
      email.isEmpty
          ? '/forgot-password'
          : '/forgot-password?email=${Uri.encodeQueryComponent(email)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
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
                const Center(child: QazanLogo(size: 76)),
                const SizedBox(height: AppSpacing.xl),
                Text(s.welcome, style: AppTextStyles.display),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  s.loginSub,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                AppTextField(
                  label: s.phoneOrEmail,
                  hint: s.phoneOrEmailHint,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) {
                    final String val = (v ?? '').trim();
                    final bool ok =
                        val.contains('@') || PhoneUtil.isValid(val);
                    return ok ? null : s.phoneOrEmailInvalid;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: s.password,
                  hint: '••••••••',
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
                      (v == null || v.length < 4) ? s.passwordShort : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _forgotPassword(context),
                    child: Text(s.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: s.login,
                  loading: auth.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.xl),
                const SocialButtons(),
                const SizedBox(height: AppSpacing.xl),
                if (!AppVariant.isBusinessApp)
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(s.noAccount, style: AppTextStyles.bodySm),
                      TextButton(
                        onPressed: () => context.push(
                          '/register',
                        ),
                        child: Text(s.register),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const LegalFooterLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
