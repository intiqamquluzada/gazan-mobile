import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Azerbaijani label for a backend role code.
String roleLabel(String role) {
  switch (role) {
    case 'ADMIN':
      return 'Admin';
    case 'BUSINESS_OWNER':
      return 'Biznes';
    case 'CUSTOMER':
    default:
      return 'Müştəri';
  }
}

Color roleColor(String role) {
  switch (role) {
    case 'ADMIN':
      return AppColors.accent;
    case 'BUSINESS_OWNER':
      return AppColors.info;
    case 'CUSTOMER':
    default:
      return AppColors.success;
  }
}

/// Compact metric card used on the admin dashboard.
class AdminStatTile extends StatelessWidget {
  const AdminStatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.tint,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: tint),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTextStyles.display.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

/// Small colored pill showing a user's role.
class AdminRoleBadge extends StatelessWidget {
  const AdminRoleBadge({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final Color c = roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        roleLabel(role),
        style: AppTextStyles.caption.copyWith(
          color: c,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
