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
import '../../../core/widgets/brand_header.dart';
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

    final AppPalette p = context.palette;
    final bool canPop = GoRouter.of(context).canPop();

    return Scaffold(
      appBar: canPop
          ? AppBar(leadingWidth: 72, leading: const CircleBackButton())
          : null,
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.xl,
            ),
            children: <Widget>[
              // ── Brand ─────────────────────────────────────────────
              const Center(child: BrandMark(size: 26)),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Container(
                  width: 214,
                  height: 160,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[Color(0xFFE2F1DA), Color(0x00E2F1DA)],
                      stops: <double>[0.55, 1],
                    ),
                  ),
                  child: Image.asset(
                    'assets/illustrations/login_card.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // ── Welcome ───────────────────────────────────────────
              Text(
                s.welcome,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(
                  color: context.palette.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.loginTagline,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(
                  fontSize: 14,
                  color: p.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // ── Form ──────────────────────────────────────────────
              AppTextField(
                label: s.phoneOrEmail,
                showLabel: false,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.username],
                validator: (String? v) {
                  final String val = (v ?? '').trim();
                  final bool ok = val.contains('@') || PhoneUtil.isValid(val);
                  return ok ? null : s.phoneOrEmailInvalid;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: s.password,
                showLabel: false,
                controller: _password,
                obscure: _obscure,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.password],
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
                  child: Text(
                    s.forgotPassword,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: s.login,
                trailingIcon: Icons.arrow_forward_rounded,
                loading: auth.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              const SocialButtons(),
              const SizedBox(height: AppSpacing.md),
              if (!AppVariant.isBusinessApp)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      s.noAccount,
                      style: AppTextStyles.bodySm
                          .copyWith(fontSize: 14, color: p.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        s.register,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xs),
              const LegalFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }
}
