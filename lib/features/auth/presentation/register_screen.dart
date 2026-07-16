import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/location/default_country.dart';
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
  bool _obscure = true;
  DateTime? _birthDate;
  String _passwordValue = '';

  /// Selected phone dial code (e.g. "+994"). Defaults to Azerbaijan and is
  /// refined by IP/region once [defaultCountryCodeProvider] resolves.
  String _dialCode = '+994';
  String _isoCode = 'AZ';

  static final RegExp _phonePattern = RegExp(r'^[0-9 ()-]{4,20}$');

  // Password policy: 8+ chars, at least one letter and one digit.
  static final RegExp _hasLetter = RegExp(r'[A-Za-zƏəÇçĞğıİÖöŞşÜü]');
  static final RegExp _hasDigit = RegExp(r'[0-9]');

  String? _passwordError(String v) {
    final S s = ref.read(sProvider);
    if (v.length < 8) return s.pwErrMin8;
    if (!_hasLetter.hasMatch(v)) return s.pwErrLetter;
    if (!_hasDigit.hasMatch(v)) return s.pwErrDigit;
    return null;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime initial =
        _birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: ref.read(sProvider).pickBirthDate,
      cancelText: ref.read(sProvider).cancel,
      confirmText: ref.read(sProvider).selectAction,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  /// Combines the selected dial code with the typed local number, e.g.
  /// "+994" + "50 123 45 67" → "+99450 123 45 67". Returns null when the
  /// number is blank (phone is optional).
  String? _fullPhone() {
    final String local = _phone.text.trim();
    if (local.isEmpty) return null;
    return '$_dialCode$local';
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).signUp(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            role: widget.role,
            phone: _fullPhone(),
            birthDate: _birthDate,
          );
    } catch (_) {
      if (!mounted) return;
      final String msg = ref.read(authControllerProvider).error ??
          ref.read(sProvider).registrationFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }
    if (!mounted) return;
    final UserRole effective =
        ref.read(currentUserProvider)?.role ?? widget.role;
    context.go(effective.landingPath);
  }

  /// A tappable, read-only field that opens the date picker. Built by hand
  /// (not [AppTextField]) because that widget disables itself when read-only,
  /// which would swallow the tap.
  Widget _birthDateField(BuildContext context) {
    final S s = ref.watch(sProvider);
    final ThemeData theme = Theme.of(context);
    final bool hasValue = _birthDate != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          s.birthDateOptional,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: _pickBirthDate,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.cake_outlined, size: 20),
            ),
            child: Text(
              hasValue ? _formatDate(_birthDate!) : s.pickDate,
              style: AppTextStyles.body.copyWith(
                color: hasValue
                    ? theme.colorScheme.onSurface
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Phone number field with a country-code picker on the left. The
  /// picker defaults to Azerbaijan and updates to the IP/region country
  /// once [defaultCountryCodeProvider] resolves.
  Widget _phoneField() {
    final S s = ref.watch(sProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          s.phone,
          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: <Widget>[
              CountryCodePicker(
                onChanged: (CountryCode c) {
                  setState(() {
                    _dialCode = c.dialCode ?? _dialCode;
                    _isoCode = c.code ?? _isoCode;
                  });
                },
                initialSelection: _isoCode,
                favorite: const <String>['+994', 'AZ', '+90', '+7'],
                showFlag: true,
                showDropDownButton: true,
                padding: EdgeInsets.zero,
                textStyle: AppTextStyles.body,
              ),
              const SizedBox(
                height: 24,
                child: VerticalDivider(width: 1),
              ),
              Expanded(
                child: TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: '50 123 45 67',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  ),
                  validator: (String? v) {
                    final String val = (v ?? '').trim();
                    if (val.isEmpty) return null; // optional
                    return _phonePattern.hasMatch(val)
                        ? null
                        : s.phoneNumberInvalid;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AuthState auth = ref.watch(authControllerProvider);

    // Apply the IP/region-derived default country the first time it
    // resolves (only if the user hasn't already picked one).
    ref.listen<AsyncValue<String>>(defaultCountryCodeProvider,
        (AsyncValue<String>? prev, AsyncValue<String> next) {
      final String? cc = next.value;
      if (cc != null && cc != _isoCode && _phone.text.isEmpty) {
        try {
          final CountryCode resolved = CountryCode.fromCountryCode(cc);
          final String? dial = resolved.dialCode;
          if (dial != null && dial.isNotEmpty) {
            setState(() {
              _isoCode = cc;
              _dialCode = dial;
            });
          }
        } catch (_) {
          // Unknown ISO code — keep the current default.
        }
      }
    });

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
                      ? s.promoteBusiness
                      : s.createAccount,
                  style: AppTextStyles.display,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.role == UserRole.business
                      ? s.registerBusinessSub
                      : s.registerCustomerSub,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                AppTextField(
                  label: widget.role == UserRole.business
                      ? s.businessName
                      : s.fullName,
                  hint: widget.role == UserRole.business
                      ? s.businessNameHint
                      : s.fullNameHint,
                  controller: _name,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) =>
                      (v == null || v.trim().length < 2)
                          ? s.enterNameShort
                          : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: s.email,
                  hint: s.emailHint,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.alternate_email_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) =>
                      (v == null || !v.contains('@')) ? s.invalidEmail : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                _phoneField(),
                const SizedBox(height: AppSpacing.lg),
                _birthDateField(context),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: s.password,
                  hint: s.passwordHintMin8,
                  controller: _password,
                  obscure: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  onChanged: (String v) => setState(() => _passwordValue = v),
                  suffix: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (String? v) => _passwordError(v ?? ''),
                ),
                const SizedBox(height: AppSpacing.md),
                _PasswordChecklist(value: _passwordValue),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: s.createAccount,
                  loading: auth.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(s.haveAccount, style: AppTextStyles.bodySm),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(s.login),
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

/// Live password-policy checklist shown under the password field. Each
/// rule turns green with a check once satisfied, so the user sees exactly
/// what's still missing while typing.
class _PasswordChecklist extends ConsumerWidget {
  const _PasswordChecklist({required this.value});

  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final bool lenOk = value.length >= 8;
    final bool letterOk =
        RegExp(r'[A-Za-zƏəÇçĞğıİÖöŞşÜü]').hasMatch(value);
    final bool digitOk = RegExp(r'[0-9]').hasMatch(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _rule(s.pwRuleMin8, lenOk),
        const SizedBox(height: 4),
        _rule(s.pwRuleLetter, letterOk),
        const SizedBox(height: 4),
        _rule(s.pwRuleDigit, digitOk),
      ],
    );
  }

  Widget _rule(String label, bool ok) {
    final Color color = ok ? AppColors.success : AppColors.textTertiary;
    return Row(
      children: <Widget>[
        Icon(
          ok ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: color),
        ),
      ],
    );
  }
}
