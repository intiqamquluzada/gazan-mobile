import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/profile_settings_controller.dart';
import '_sheet_handle.dart';

class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NotificationPrefs prefs = ref.watch(notificationPrefsProvider);
    final NotificationPrefsController ctrl =
        ref.read(notificationPrefsProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SheetHandle(),
          const SizedBox(height: AppSpacing.lg),
          Text('Bildirişlər', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text('Hansı hadisələrdən xəbərdar olmaq istəyirsən?',
              style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.lg),
          _NotifTile(
            title: 'Yeni mükafat',
            subtitle: 'Bir kart tamamlananda dərhal məlumat ver',
            icon: Icons.celebration_rounded,
            tint: AppColors.success,
            value: prefs.newRewards,
            onChanged: ctrl.toggleNewRewards,
          ),
          _NotifTile(
            title: 'Yaxınlıqdakı təkliflər',
            subtitle: 'Sənin yerlərində yeni promo başlayanda xəbərdar et',
            icon: Icons.location_on_outlined,
            tint: AppColors.info,
            value: prefs.nearbyOffers,
            onChanged: ctrl.toggleNearbyOffers,
          ),
          _NotifTile(
            title: 'Həftəlik xülasə',
            subtitle: 'Hər bazar nə qədər qazandığını göndər',
            icon: Icons.calendar_today_outlined,
            tint: AppColors.warning,
            value: prefs.weeklyRecap,
            onChanged: ctrl.toggleWeeklyRecap,
          ),
          _NotifTile(
            title: 'Marketinq və promosiyalar',
            subtitle: 'Yeni biznes və xüsusi kampaniyalar',
            icon: Icons.campaign_outlined,
            tint: AppColors.primary,
            value: prefs.marketing,
            onChanged: ctrl.toggleMarketing,
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Bağla'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: Text(title, style: AppTextStyles.bodyLg),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(subtitle, style: AppTextStyles.bodySm),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: tint),
        ),
      ),
    );
  }
}
