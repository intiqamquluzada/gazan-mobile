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
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/auth_controller.dart';
import '../data/auth_remote_data_source.dart';
import '../domain/user_role.dart';
import 'social_buttons.dart';

enum _Step { phone, verify, details, password }

/// Sign-up. A customer goes phone → (verification, once SMS exists) → name,
/// email and birth date → password. A business fills one form.
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
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  late UserRole _role = widget.initialRole;
  _Step _step = _Step.phone;
  bool _obscure = true;
  bool _busy = false;
  bool _birthDateMissing = false;
  DateTime? _birthDate;
  String _passwordValue = '';
  String _dialCode = '+994';

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
      setState(() => _step = _Step.password);
    }
  }

  Future<void> _createAccount() async {
    if (!_form.currentState!.validate()) return;
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
          );
    } catch (_) {
      if (!mounted) return;
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
          leading: BackButton(onPressed: _back),
          title: !_isBusiness && _step != _Step.phone
              ? Text(s.stepOf(_visibleStep, 3))
              : null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
            child: Form(
              key: _form,
              child: ListView(
                children: _isBusiness ? _businessForm(s) : _customerStep(s),
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
        _Step.password => 3,
      };

  Widget _roleSwitch(S s) => SegmentedButton<UserRole>(
        segments: <ButtonSegment<UserRole>>[
          ButtonSegment<UserRole>(
            value: UserRole.customer,
            icon: const Icon(Icons.person_outline_rounded, size: 18),
            label: Text(s.roleCustomer),
          ),
          ButtonSegment<UserRole>(
            value: UserRole.business,
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: Text(s.roleBusiness),
          ),
        ],
        selected: <UserRole>{_role},
        onSelectionChanged: (Set<UserRole> v) => setState(() {
          _role = v.first;
          _step = _Step.phone;
        }),
      );

  Widget _heading(String title, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextStyles.display),
          const SizedBox(height: AppSpacing.sm),
          Text(sub,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xxl),
        ],
      );

  Widget _haveAccount(S s) => Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(s.haveAccount, style: AppTextStyles.bodySm),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(s.login),
            ),
          ],
        ),
      );

  List<Widget> _customerStep(S s) {
    switch (_step) {
      case _Step.phone:
        return <Widget>[
          _roleSwitch(s),
          const SizedBox(height: AppSpacing.xl),
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
            decoration: InputDecoration(labelText: s.regVerifyCode),
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
            label: s.firstName,
            controller: _first,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (String? v) =>
                (v == null || v.trim().length < 2) ? s.enterNameShort : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
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
          PrimaryButton(label: s.continueAction, onPressed: _submitDetails),
        ];
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
          loading: ref.watch(authControllerProvider).isLoading,
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
