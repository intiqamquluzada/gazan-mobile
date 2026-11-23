import 'dart:async';

import '../../../core/legal/legal_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/phone_util.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/brand_header.dart';
import '../../../core/widgets/otp_code_field.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/application/profile_settings_controller.dart';
import '../application/auth_controller.dart';
import '../data/auth_remote_data_source.dart';
import '../domain/user_role.dart';
import 'social_buttons.dart';

enum _Step { phone, verify, details, emailCode, password }

/// Sign-up. A customer goes phone → (verification, once SMS exists) → name,
/// email and birth date → emailed code → password. A business fills one
/// form, then confirms the emailed code and the account is created.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.initialRole = UserRole.customer});

  final UserRole initialRole;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _first = TextEditingController();
  final TextEditingController _last = TextEditingController();
  final TextEditingController _businessName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final TextEditingController _emailCode = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  late UserRole _role = widget.initialRole;
  _Step _step = _Step.phone;
  bool _obscure = true;
  bool _busy = false;
  bool _birthDateMissing = false;
  DateTime? _birthDate;
  String _passwordValue = '';
  String _dialCode = '+994';

  // Email OTP: the ticket from /auth/email/verify, and the address it is for.
  String? _emailTicket;
  String? _ticketEmail;
  bool _codeError = false;
  bool _verifying = false;
  int _resendIn = 0;
  Timer? _resendTimer;

  static final RegExp _hasLetter = RegExp(r'[A-Za-zƏəÇçĞğıİÖöŞşÜü]');
  static final RegExp _hasDigit = RegExp(r'[0-9]');

  bool get _isBusiness => _role == UserRole.business;

  String get _fullPhone => PhoneUtil.normalize(_phone.text, _dialCode);

  String? _passwordError(String v) {
    final S s = ref.read(sProvider);
    if (v.length < 8) return s.pwErrMin8;
    if (!_hasLetter.hasMatch(v)) return s.pwErrLetter;
    if (!_hasDigit.hasMatch(v)) return s.pwErrDigit;
    return null;
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _businessName.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _code.dispose();
    _emailCode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickBirthDate() async {
    final S s = ref.read(sProvider);
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: s.pickBirthDate,
      cancelText: s.cancel,
      confirmText: s.selectAction,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateMissing = false;
      });
    }
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _submitPhone() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final String phone = _fullPhone;
    try {
      final PhoneStartResult r =
          await ref.read(authRemoteDataSourceProvider).phoneStart(phone);
      if (!mounted) return;
      if (r.registered) {
        _toast(ref.read(sProvider).phoneAlreadyRegistered);
        context.go('/login?identifier=${Uri.encodeQueryComponent(phone)}');
        return;
      }
      setState(() =>
          _step = r.verificationRequired ? _Step.verify : _Step.details);
    } on ApiException catch (e) {
      if (mounted) _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submitDetails() {
    final bool valid = _form.currentState!.validate();
    if (_birthDate == null) setState(() => _birthDateMissing = true);
    if (valid && _birthDate != null) {
      if (_emailVerified) {
        setState(() => _step = _Step.password);
      } else {
        _sendEmailCode();
      }
    }
  }

  String get _normalizedEmail => _email.text.trim().toLowerCase();

  /// True when the address in the field already passed the code step.
  bool get _emailVerified =>
      _emailTicket != null && _ticketEmail == _normalizedEmail;

  /// Mails a code and opens the code step (or just restarts the countdown
  /// when resending from it).
  Future<void> _sendEmailCode({bool resend = false}) async {
    setState(() => _busy = true);
    try {
      await ref.read(authRemoteDataSourceProvider).emailStart(
            _email.text.trim(),
            locale: ref.read(languageProvider).toUpperCase(),
          );
      if (!mounted) return;
      _emailCode.clear();
      setState(() {
        _codeError = false;
        _step = _Step.emailCode;
      });
      _startResendCountdown();
      if (resend) _toast(ref.read(sProvider).emailCodeResent);
    } on ApiException catch (e) {
      if (mounted) _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendIn = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted || _resendIn <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendIn = 0);
        return;
      }
      setState(() => _resendIn--);
    });
  }

  Future<void> _verifyEmailCode() async {
    final S s = ref.read(sProvider);
    final String code = _emailCode.text;
    if (code.length != 6) {
      setState(() => _codeError = true);
      _toast(s.emailCodeIncomplete);
      return;
    }
    if (_verifying) return;
    setState(() => _verifying = true);
    try {
      final String ticket = await ref
          .read(authRemoteDataSourceProvider)
          .emailVerify(_email.text.trim(), code);
      if (!mounted) return;
      _emailTicket = ticket;
      _ticketEmail = _normalizedEmail;
      _resendTimer?.cancel();
      if (_isBusiness) {
        // The form was already validated: create the account right away.
        await _signUp();
      } else {
        setState(() => _step = _Step.password);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _emailCode.clear();
      setState(() => _codeError = true);
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _createAccount() async {
    if (!_form.currentState!.validate()) return;
    if (!_emailVerified) {
      // Business sign-up: prove the address first.
      await _sendEmailCode();
      return;
    }
    await _signUp();
  }

  Future<void> _signUp() async {
    final String fullName = _isBusiness
        ? _businessName.text.trim()
        : '${_first.text.trim()} ${_last.text.trim()}';
    try {
      await ref.read(authControllerProvider.notifier).signUp(
            fullName: fullName,
            email: _email.text.trim(),
            password: _password.text,
            role: _role,
            phone: _fullPhone,
            birthDate: _birthDate,
            emailVerificationToken: _emailTicket,
          );
    } catch (_) {
      if (!mounted) return;
      // Back to the form so the user can fix what the server rejected.
      if (_step == _Step.emailCode) setState(() => _step = _Step.phone);
      _toast(ref.read(authControllerProvider).error ??
          ref.read(sProvider).registrationFailed);
      return;
    }
    if (!mounted) return;
    context.go((ref.read(currentUserProvider)?.role ?? _role).landingPath);
  }

  void _back() {
    switch (_step) {
      case _Step.phone:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/login');
        }
      case _Step.verify:
        setState(() => _step = _Step.phone);
      case _Step.details:
        setState(() => _step = _Step.phone);
      case _Step.emailCode:
        // A business has a single form; it lives on the first step.
        setState(() => _step = _isBusiness ? _Step.phone : _Step.details);
      case _Step.password:
        setState(() => _step = _Step.details);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return PopScope(
      canPop: _step == _Step.phone,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 72,
          leading: CircleBackButton(onPressed: _back),
          title: !_isBusiness && _step != _Step.phone
              ? Text(s.stepOf(_visibleStep, 4))
              : null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
            child: Form(
              key: _form,
              child: ListView(
                children: _step == _Step.emailCode
                    ? _emailCodeStep(s)
                    : _isBusiness
                        ? _businessForm(s)
                        : _customerStep(s),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int get _visibleStep => switch (_step) {
        _Step.phone || _Step.verify => 1,
        _Step.details => 2,
        _Step.emailCode => 3,
        _Step.password => 4,
      };

  /// Six-tile code entry for the emailed sign-up code.
  List<Widget> _emailCodeStep(S s) {
    final AppPalette p = context.palette;
    final bool loading =
        _verifying || ref.watch(authControllerProvider).isLoading;
    return <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFFFFA93A), Color(0xFFF76B15)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.actionGlow.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.mark_email_unread_rounded,
              color: AppColors.onDark, size: 30),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(s.emailCodeTitle,
          style: AppTextStyles.h1.copyWith(
              fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
      const SizedBox(height: AppSpacing.sm),
      Text.rich(
        TextSpan(
          style: AppTextStyles.body.copyWith(color: p.textSecondary),
          children: <InlineSpan>[
            TextSpan(text: '${s.emailCodeSub} '),
            TextSpan(
              text: _email.text.trim(),
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: p.textPrimary),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.xxl),
      OtpCodeField(
        controller: _emailCode,
        hasError: _codeError,
        enabled: !loading,
        onChanged: (_) {
          if (_codeError) setState(() => _codeError = false);
        },
        onCompleted: (_) => _verifyEmailCode(),
      ),
      const SizedBox(height: AppSpacing.md),
      Text(s.emailCodeSpam,
          style: AppTextStyles.bodySm.copyWith(color: p.textTertiary)),
      const SizedBox(height: AppSpacing.xxl),
      PrimaryButton(
        label: _isBusiness ? s.createAccount : s.emailCodeVerify,
        icon: Icons.verified_rounded,
        loading: loading,
        onPressed: _verifyEmailCode,
      ),
      const SizedBox(height: AppSpacing.md),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton.icon(
            onPressed: _resendIn > 0 || _busy || loading
                ? null
                : () => _sendEmailCode(resend: true),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(_resendIn > 0
                ? s.emailCodeResendIn(_resendIn)
                : s.emailCodeResend),
          ),
          TextButton(
            onPressed: loading ? null : _back,
            child: Text(s.emailCodeChange),
          ),
        ],
      ),
    ];
  }

  /// Brand block + customer / business switch shown on the first page.
  Widget _roleSwitch(S s) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const BrandHeader(logoSize: 42, subtitle: false),
          const SizedBox(height: AppSpacing.xl),
          PillToggle<UserRole>(
            options: <({UserRole value, IconData icon, String label})>[
              (
                value: UserRole.customer,
                icon: Icons.person_outline_rounded,
                label: s.roleCustomer,
              ),
              (
                value: UserRole.business,
                icon: Icons.storefront_outlined,
                label: s.roleBusiness,
              ),
            ],
            value: _role,
            onChanged: (UserRole v) => setState(() {
              _role = v;
              _step = _Step.phone;
            }),
          ),
        ],
      );

  Widget _heading(String title, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style: AppTextStyles.h1.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2)),
          const SizedBox(height: AppSpacing.sm),
          Text(sub,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xxl),
        ],
      );

  Widget _haveAccount(S s) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              s.haveAccount,
              style: AppTextStyles.bodySm.copyWith(
                  fontSize: 14, color: context.palette.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              s.login,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );

  List<Widget> _customerStep(S s) {
    switch (_step) {
      case _Step.phone:
        return <Widget>[
          _roleSwitch(s),
          const SizedBox(height: AppSpacing.xxl),
          _heading(s.regPhoneTitle, s.regPhoneSub),
          PhoneField(
            controller: _phone,
            onDialChanged: (String d) => _dialCode = d,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitPhone(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: s.continueAction,
            trailingIcon: Icons.arrow_forward_rounded,
            loading: _busy,
            onPressed: _submitPhone,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SocialButtons(),
          const SizedBox(height: AppSpacing.lg),
          _haveAccount(s),
        ];
      case _Step.verify:
        // SMS is not live yet; the server reports verificationRequired=false
        // and this step is skipped. The code plugs in here when it arrives.
        return <Widget>[
          _heading(s.regVerifyTitle, '${s.regVerifySub} $_fullPhone'),
          TextFormField(
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(hintText: s.hintVerifyCode, labelText: s.regVerifyCode),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: s.continueAction,
            onPressed: () => setState(() => _step = _Step.details),
          ),
        ];
      case _Step.details:
        return <Widget>[
          _heading(s.regDetailsTitle, _fullPhone),
          AppTextField(
            hint: s.hintFirstName,
            label: s.firstName,
            controller: _first,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (String? v) =>
                (v == null || v.trim().length < 2) ? s.enterNameShort : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            hint: s.hintLastName,
            label: s.lastName,
            controller: _last,
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            validator: (String? v) =>
                (v == null || v.trim().length < 2) ? s.enterNameShort : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _emailField(s),
          const SizedBox(height: AppSpacing.lg),
          _birthDateField(s, optional: false),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: s.continueAction,
            loading: _busy,
            onPressed: _submitDetails,
          ),
        ];
      case _Step.emailCode:
        return _emailCodeStep(s);
      case _Step.password:
        return <Widget>[
          _heading(s.regPasswordTitle, s.regPasswordSub),
          ..._passwordFields(s),
          const SizedBox(height: AppSpacing.xl),
          const LegalConsentText(),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: s.createAccount,
            loading: ref.watch(authControllerProvider).isLoading,
            onPressed: _createAccount,
          ),
        ];
    }
  }

  List<Widget> _businessForm(S s) => <Widget>[
        _roleSwitch(s),
        const SizedBox(height: AppSpacing.xl),
        _heading(s.promoteBusiness, s.registerBusinessSub),
        AppTextField(
          label: s.businessName,
          hint: s.businessNameHint,
          controller: _businessName,
          prefixIcon: Icons.storefront_outlined,
          textInputAction: TextInputAction.next,
          validator: (String? v) =>
              (v == null || v.trim().length < 2) ? s.enterNameShort : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        _emailField(s),
        const SizedBox(height: AppSpacing.lg),
        PhoneField(
          controller: _phone,
          onDialChanged: (String d) => _dialCode = d,
        ),
        const SizedBox(height: AppSpacing.lg),
        ..._passwordFields(s),
        const SizedBox(height: AppSpacing.xl),
        const LegalConsentText(),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: s.createAccount,
          loading: _busy || ref.watch(authControllerProvider).isLoading,
          onPressed: _createAccount,
        ),
        const SizedBox(height: AppSpacing.lg),
        _haveAccount(s),
      ];

  Widget _emailField(S s) => AppTextField(
        label: s.email,
        hint: s.emailHint,
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        prefixIcon: Icons.alternate_email_rounded,
        textInputAction: TextInputAction.next,
        validator: (String? v) =>
            (v == null || !v.contains('@')) ? s.invalidEmail : null,
      );

  List<Widget> _passwordFields(S s) => <Widget>[
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
      ];

  /// A tappable, read-only field that opens the date picker. Built by hand
  /// (not [AppTextField]) because that widget disables itself when read-only,
  /// which would swallow the tap.
  Widget _birthDateField(S s, {required bool optional}) {
    final ThemeData theme = Theme.of(context);
    final DateTime? value = _birthDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          optional ? s.birthDateOptional : s.birthDateLabel,
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
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.cake_outlined, size: 20),
              errorText: _birthDateMissing ? s.birthDateRequired : null,
            ),
            child: Text(
              value != null ? _formatDate(value) : s.pickDate,
              style: AppTextStyles.body.copyWith(
                color: value != null
                    ? theme.colorScheme.onSurface
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ],
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
    final bool letterOk = RegExp(r'[A-Za-zƏəÇçĞğıİÖöŞşÜü]').hasMatch(value);
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
