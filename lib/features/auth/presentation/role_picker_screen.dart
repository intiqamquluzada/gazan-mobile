import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/user_role.dart';

class RolePickerScreen extends StatelessWidget {
  const RolePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AppSpacing.xxxl),
              Text('Sən kimsən?', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Hesab yaratmaq üçün rolunu seç. İstənilən vaxt dəyişə bilərsən.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _RoleCard(
                role: UserRole.customer,
                title: AppStrings.iAmCustomer,
                subtitle: AppStrings.customerHint,
                emoji: '🙋',
                onTap: () => context.push('/login?role=customer'),
              ),
              const SizedBox(height: AppSpacing.lg),
              _RoleCard(
                role: UserRole.business,
                title: AppStrings.iAmBusiness,
                subtitle: AppStrings.businessHint,
                emoji: '🏪',
                onTap: () => context.push('/login?role=business'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.onTap,
  });

  final UserRole role;
  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
