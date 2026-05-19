import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/profile_remote_data_source.dart';
import '_sheet_handle.dart';

class SecuritySheet extends ConsumerStatefulWidget {
  const SecuritySheet({super.key});

  @override
  ConsumerState<SecuritySheet> createState() => _SecuritySheetState();
}

class _SecuritySheetState extends ConsumerState<SecuritySheet> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileRemoteDataSourceProvider).changePassword(
            currentPassword: _current.text,
            newPassword: _new.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifrə yeniləndi ✓')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xəta: $e')),
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
              Text('Şifrəni dəyiş', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Hazırkı şifrə',
                controller: _current,
                obscure: true,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (String? v) =>
                    (v == null || v.isEmpty) ? 'Daxil et' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Yeni şifrə',
                controller: _new,
                obscure: true,
                prefixIcon: Icons.lock_reset_rounded,
                validator: (String? v) =>
                    (v == null || v.length < 8) ? '8+ simvol olsun' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Yeni şifrəni təkrarla',
                controller: _confirm,
                obscure: true,
                prefixIcon: Icons.lock_reset_rounded,
                validator: (String? v) =>
                    v != _new.text ? 'Şifrələr uyğun gəlmir' : null,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Yadda saxla',
                icon: Icons.check_rounded,
                loading: _saving,
                onPressed: _saving ? null : _save,
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
