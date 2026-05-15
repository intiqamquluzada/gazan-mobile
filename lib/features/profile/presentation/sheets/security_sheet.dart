import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '_sheet_handle.dart';

class SecuritySheet extends StatefulWidget {
  const SecuritySheet({super.key});

  @override
  State<SecuritySheet> createState() => _SecuritySheetState();
}

class _SecuritySheetState extends State<SecuritySheet> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  bool _biometric = true;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şifrə yeniləndi')),
    );
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
              Text('Təhlükəsizlik', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xl),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _biometric,
                onChanged: (bool v) => setState(() => _biometric = v),
                secondary: const Icon(Icons.fingerprint_rounded),
                title: Text('Biometrik daxil olma',
                    style: AppTextStyles.bodyLg),
                subtitle: Text('Face ID və ya barmaq izi ilə açılış',
                    style: AppTextStyles.bodySm),
              ),
              const Divider(height: AppSpacing.xl),
              Text('Şifrəni dəyiş', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
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
                    (v == null || v.length < 6) ? '6+ simvol olsun' : null,
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
