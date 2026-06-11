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
  bool _obscure = true;
  DateTime? _birthDate;

  static final RegExp _phonePattern = RegExp(r'^\+?[0-9 ()-]{6,32}$');

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
      helpText: 'Doğum tarixini seç',
      cancelText: 'Ləğv et',
      confirmText: 'Seç',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).signUp(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            role: widget.role,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            birthDate: _birthDate,
          );
    } catch (_) {
      if (!mounted) return;
      final String msg =
          ref.read(authControllerProvider).error ?? 'Qeydiyyat alınmadı';
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
    final ThemeData theme = Theme.of(context);
    final bool hasValue = _birthDate != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Doğum tarixi (istəyə bağlı)',
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
              hasValue ? _formatDate(_birthDate!) : 'Tarixi seç',
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
                  label: AppStrings.phone,
                  hint: '+994 ...',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) {
                    final String s = (v ?? '').trim();
                    if (s.isEmpty) return null; // optional
                    return _phonePattern.hasMatch(s)
                        ? null
                        : 'Telefon nömrəsi düzgün deyil';
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _birthDateField(context),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: AppStrings.password,
                  hint: '8+ simvol',
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
                      (v == null || v.length < 8) ? '8+ simvol olsun' : null,
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
