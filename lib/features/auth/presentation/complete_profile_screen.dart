import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/phone_util.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/data/profile_remote_data_source.dart';
import '../application/auth_controller.dart';
import '../domain/app_user.dart';

/// Asked once, right after a Google / Apple sign-up: those accounts start
/// without a phone number, and the number is how venues find a customer.
/// The router keeps the user here until the profile is complete.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  late final TextEditingController _name;
  late final TextEditingController _email;
  String _dialCode = '+994';
  DateTime? _birthDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final AppUser? u = ref.read(currentUserProvider);
    _name = TextEditingController(text: u?.fullName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _birthDate = u?.birthDate;
  }

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
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
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final AuthController auth = ref.read(authControllerProvider.notifier);
    try {
      final AppUser updated =
          await ref.read(profileRemoteDataSourceProvider).updateProfile(
                fullName: _name.text.trim(),
                phone: PhoneUtil.normalize(_phone.text, _dialCode),
                birthDate: _birthDate,
              );
      // The router moves on as soon as the profile reads complete.
      auth.applyUser(updated);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final DateTime? d = _birthDate;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            child: Text(s.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: <Widget>[
              Text(s.completeProfileTitle, style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              Text(s.completeProfileSub, style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.xxl),
              PhoneField(
                controller: _phone,
                onDialChanged: (String v) => _dialCode = v,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: s.fullName,
                controller: _name,
                prefixIcon: Icons.person_outline_rounded,
                validator: (String? v) =>
                    (v == null || v.trim().length < 2) ? s.enterNameShort : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_email.text.isNotEmpty) ...<Widget>[
                AppTextField(
                  label: s.email,
                  controller: _email,
                  readOnly: true,
                  prefixIcon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(s.birthDateOptional,
                  style: AppTextStyles.bodySm
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.cake_outlined, size: 20),
                  ),
                  child: Text(
                    d == null
                        ? s.pickDate
                        : '${d.day.toString().padLeft(2, '0')}.'
                            '${d.month.toString().padLeft(2, '0')}.${d.year}',
                    style: AppTextStyles.body,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: s.continueAction,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown by the Windows app to an account that is neither owner nor cashier.
class BusinessOnlyScreen extends ConsumerWidget {
  const BusinessOnlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.storefront_outlined, size: 56),
              const SizedBox(height: AppSpacing.lg),
              Text(s.businessOnlyTitle,
                  textAlign: TextAlign.center, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.sm),
              Text(s.businessOnlyBody,
                  textAlign: TextAlign.center, style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
                child: Text(s.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
