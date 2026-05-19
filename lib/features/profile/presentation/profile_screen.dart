import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/user_role.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_card.dart';
import '../application/profile_settings_controller.dart';
import 'sheets/edit_profile_sheet.dart';
import 'sheets/help_sheet.dart';
import 'sheets/language_sheet.dart';
import 'sheets/notifications_sheet.dart';
import 'sheets/security_sheet.dart';
import 'sheets/theme_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppUser? user = ref.watch(currentUserProvider);
    final AsyncValue<List<LoyaltyCard>> cards = ref.watch(myCardsProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final String language = ref.watch(languageProvider);

    final int totalRewards = cards.maybeWhen(
      data: (List<LoyaltyCard> list) => list.fold(
        0,
        (int s, LoyaltyCard c) => s + c.totalRewardsClaimed,
      ),
      orElse: () => 0,
    );
    final int activeCards = cards.maybeWhen(
      data: (List<LoyaltyCard> list) => list.length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: <Widget>[
          // ── Header ──
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: <Widget>[
                Avatar(name: user?.fullName ?? 'Qonaq', size: 56),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(user?.fullName ?? 'Qonaq',
                          style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '',
                          style: AppTextStyles.bodySm),
                      if (user?.phone != null && user!.phone!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(user.phone!, style: AppTextStyles.bodySm),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showSheet(
                    context,
                    const EditProfileSheet(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Stats ──
          Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  icon: Icons.card_giftcard_rounded,
                  value: '$activeCards',
                  label: 'Aktiv kart',
                  tint: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.celebration_rounded,
                  value: '$totalRewards',
                  label: 'Qazanılan mükafat',
                  tint: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Account section ──
          Text('Hesab', style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          _MenuTile(
            icon: Icons.person_outline_rounded,
            label: 'Profili düzəliş et',
            trailing: 'Ad, telefon',
            onTap: () => _showSheet(context, const EditProfileSheet()),
          ),
          _MenuTile(
            icon: Icons.notifications_none_rounded,
            label: 'Bildirişlər',
            trailing: _notifTrailing(ref),
            onTap: () => _showSheet(context, const NotificationsSheet()),
          ),
          _MenuTile(
            icon: Icons.lock_outline_rounded,
            label: 'Təhlükəsizlik',
            onTap: () => _showSheet(context, const SecuritySheet()),
          ),
          _MenuTile(
            icon: Icons.translate_rounded,
            label: 'Dil',
            trailing: _langLabel(language),
            onTap: () => _showSheet(context, const LanguageSheet()),
          ),
          _MenuTile(
            icon: Icons.brightness_6_outlined,
            label: 'Görünüş',
            trailing: _themeLabel(themeMode),
            onTap: () => _showSheet(context, const ThemeSheet()),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Help section ──
          Text('Yardım', style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            label: 'Tez-tez verilən suallar',
            onTap: () => _showSheet(context, const HelpSheet()),
          ),
          _MenuTile(
            icon: Icons.support_agent_rounded,
            label: 'Dəstəklə əlaqə',
            onTap: () => _showContactSheet(context),
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            label: 'Tətbiq haqqında',
            trailing: 'v 0.1.0',
            onTap: () => _showAbout(context),
          ),

          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Çıxış'),
            onPressed: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // ── helpers ──

  String _notifTrailing(WidgetRef ref) {
    final NotificationPrefs p = ref.watch(notificationPrefsProvider);
    final int active = <bool>[
      p.newRewards, p.nearbyOffers, p.weeklyRecap, p.marketing,
    ].where((bool e) => e).length;
    return '$active / 4 aktiv';
  }

  String _langLabel(String code) => switch (code) {
        'en' => 'English',
        'ru' => 'Русский',
        _ => 'Azərbaycanca',
      };

  String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.light => 'Açıq',
        ThemeMode.dark => 'Tünd',
        ThemeMode.system => 'Sistem',
      };

  Future<void> _showSheet(BuildContext context, Widget child) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (BuildContext _) => child,
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext _) => AlertDialog(
        title: const Text('Çıxmaq istəyirsən?'),
        content: const Text(
          'Hesabından çıxacaqsan. Yenidən daxil olaraq qayıda bilərsən.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ləğv et'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıxış'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final UserRole role =
          ref.read(currentUserProvider)?.role ?? UserRole.customer;
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) {
        context.go('/login?role=${role.name}');
      }
    }
  }

  Future<void> _showContactSheet(BuildContext context) async {
    return _showSheet(
      context,
      Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _SheetHandle(),
            const SizedBox(height: AppSpacing.lg),
            Text('Dəstəklə əlaqə', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.alternate_email_rounded),
              title: const Text('E-poçt'),
              subtitle: const Text('hello@qazan.az'),
              onTap: () => _launch('mailto:hello@qazan.az'),
            ),
            ListTile(
              leading: const Icon(Icons.phone_rounded),
              title: const Text('Telefon'),
              subtitle: const Text('+994 12 555 00 00'),
              onTap: () => _launch('tel:+994125550000'),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text('WhatsApp'),
              subtitle: const Text('Mesaj yaz — 5 dəqiqəyə cavab'),
              onTap: () => _launch('https://wa.me/994125550000'),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Bağla',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String uri) async {
    final Uri u = Uri.parse(uri);
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Qazan',
      applicationVersion: '0.1.0',
      applicationLegalese: '© 2026 Qazan. Bütün hüquqlar qorunur.',
      children: <Widget>[
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Sadiqlik və müştəri izləmə platforması — kafelər, restoranlar, '
          'salonlar üçün.',
        ),
      ],
    );
  }
}

// ────────────────────── shared sub-widgets ──────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: tint),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: AppTextStyles.display.copyWith(
                color: tint,
                fontSize: 28,
              )),
          Text(label, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
      title: Text(label, style: AppTextStyles.bodyLg),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (trailing != null)
            Text(trailing!, style: AppTextStyles.bodySm),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textTertiary),
        ],
      ),
      onTap: onTap,
    );
  }
}
