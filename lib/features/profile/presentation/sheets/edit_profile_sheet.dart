import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/domain/app_user.dart';
import '../../data/profile_remote_data_source.dart';
import '_sheet_handle.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final AppUser? u = ref.read(currentUserProvider);
    _name = TextEditingController(text: u?.fullName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final AppUser updated =
          await ref.read(profileRemoteDataSourceProvider).updateProfile(
                fullName: _name.text.trim(),
                phone: _phone.text.trim(),
              );
      ref.read(authControllerProvider.notifier).updateProfile(
            fullName: updated.fullName,
            phone: updated.phone,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil yeniləndi')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets bottom = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: bottom,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl,
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SheetHandle(),
              const SizedBox(height: AppSpacing.lg),
              Text('Profili düzəliş et', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Ad və soyad',
                controller: _name,
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: (String? v) =>
                    (v == null || v.trim().length < 2) ? 'Adı yaz' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'E-poçt',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.alternate_email_rounded,
                textInputAction: TextInputAction.next,
                validator: (String? v) =>
                    (v == null || !v.contains('@')) ? 'Düzgün e-poçt' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Telefon nömrəsi',
                controller: _phone,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Yadda saxla',
                icon: Icons.check_rounded,
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ləğv et'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
