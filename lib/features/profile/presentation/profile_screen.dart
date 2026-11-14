import '../../../core/legal/legal_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_card.dart';
import '../application/profile_settings_controller.dart';
import '../data/profile_remote_data_source.dart';
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
    final S s = ref.watch(sProvider);
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
      appBar: AppBar(title: Text(s.profile)),
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
                Avatar(
                  name: user?.fullName ?? s.guest,
                  imageUrl: user?.avatarUrl,
                  size: 56,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(user?.fullName ?? s.guest, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '', style: AppTextStyles.bodySm),
                      if (user?.phone != null &&
                          user!.phone!.isNotEmpty) ...<Widget>[
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
                  label: s.activeCard,
                  tint: AppColors.action,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.celebration_rounded,
                  value: '$totalRewards',
                  label: s.rewardsEarned,
                  tint: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Account section ──
          Text(s.account, style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          _MenuTile(
            icon: Icons.person_outline_rounded,
            label: s.editProfile,
            trailing: s.nameAndPhone,
            onTap: () => _showSheet(context, const EditProfileSheet()),
          ),
          _MenuTile(
            icon: Icons.card_giftcard_rounded,
            label: s.tabRewards,
            onTap: () => context.push('/rewards'),
          ),
          _MenuTile(
            icon: Icons.favorite_border_rounded,
            label: s.favorites,
            onTap: () => context.push('/favorites'),
          ),
          _MenuTile(
            icon: Icons.notifications_none_rounded,
            label: s.notifications,
            trailing: _notifTrailing(ref),
            onTap: () => _showSheet(context, const NotificationsSheet()),
          ),
          _MenuTile(
            icon: Icons.lock_outline_rounded,
            label: s.security,
            onTap: () => _showSheet(context, const SecuritySheet()),
          ),
          _MenuTile(
            icon: Icons.translate_rounded,
            label: s.language,
            trailing: _langLabel(language),
            onTap: () => _showSheet(context, const LanguageSheet()),
          ),
          _MenuTile(
            icon: Icons.brightness_6_outlined,
            label: s.appearance,
            trailing: _themeLabel(s, themeMode),
            onTap: () => _showSheet(context, const ThemeSheet()),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Help section ──
          Text(s.help, style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            label: s.faq,
            onTap: () => _showSheet(context, const HelpSheet()),
          ),
          _MenuTile(
            icon: Icons.support_agent_rounded,
            label: s.contactSupport,
            onTap: () => _showContactSheet(context, s),
          ),
          _MenuTile(
            icon: Icons.privacy_tip_outlined,
            label: s.privacyPolicy,
            onTap: () => openLegalPage(s.lang, LegalPage.privacy),
          ),
          _MenuTile(
            icon: Icons.description_outlined,
            label: s.termsOfUse,
            onTap: () => openLegalPage(s.lang, LegalPage.terms),
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            label: s.aboutApp,
            trailing: 'v 1.0.0',
            onTap: () => _showAbout(context, s),
          ),

          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: Text(s.logout),
            onPressed: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            icon: const Icon(Icons.delete_forever_rounded,
                color: AppColors.danger),
            label: Text(s.deleteAccount,
                style: const TextStyle(color: AppColors.dangerText)),
            onPressed: () => _confirmDeleteAccount(context, ref),
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
      p.newRewards,
      p.nearbyOffers,
      p.weeklyRecap,
      p.marketing,
    ].where((bool e) => e).length;
    return '$active / 4 ${ref.read(sProvider).notifActiveSuffix}';
  }

  String _langLabel(String code) => switch (code) {
        'en' => 'English',
        'ru' => 'Русский',
        'tr' => 'Türkçe',
        _ => 'Azərbaycanca',
      };

  String _themeLabel(S s, ThemeMode m) => switch (m) {
        ThemeMode.light => s.themeLight,
        ThemeMode.dark => s.themeDark,
        ThemeMode.system => s.themeSystem,
      };

  Future<void> _showSheet(BuildContext context, Widget child) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
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
    final S s = ref.read(sProvider);
    final bool ok = await showConfirmSheet(
      context,
      title: s.logoutTitle,
      body: s.signOutBody,
      confirmLabel: s.logout,
      cancelLabel: s.stay,
    );
    if (ok) {
      // Just clear the session — the router's auth refresh listener
      // redirects to the role picker on its own. No manual navigation,
      // so there's no race between sign-out and screen disposal.
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    final S s = ref.read(sProvider);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(s.deleteAccountTitle),
        content: Text(s.deleteAccountBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            // Content-sized: the theme's full-width minimum cannot be laid
            // out inside the dialog's action row.
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerText,
                minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.deleteAccount),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(profileRemoteDataSourceProvider).deleteAccount();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('${s.accountDeleteFailed}: $e')),
      );
      return;
    }
    // Drop the (now revoked) session — the router redirects to /role.
    await ref.read(authControllerProvider.notifier).signOut();
  }

  Future<void> _showContactSheet(BuildContext context, S s) async {
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
            Text(s.contactSupport, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.alternate_email_rounded),
              title: Text(s.email),
              subtitle: const Text('hello@qazan.az'),
              onTap: () => _launch('mailto:hello@qazan.az'),
            ),
            ListTile(
              leading: const Icon(Icons.phone_rounded),
              title: Text(s.phoneWord),
              subtitle: const Text('+994 12 555 00 00'),
              onTap: () => _launch('tel:+994125550000'),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text('WhatsApp'),
              subtitle: Text(s.whatsappSub),
              onTap: () => _launch('https://wa.me/994125550000'),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: s.close,
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

  void _showAbout(BuildContext context, S s) {
    showAboutDialog(
      context: context,
      applicationName: 'Qazan',
      applicationVersion: '1.0.0',
      applicationLegalese: s.allRightsReserved,
      children: <Widget>[
        const SizedBox(height: AppSpacing.md),
        Text(s.aboutBody),
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
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
      title: Text(label, style: AppTextStyles.bodyLg),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (trailing != null) Text(trailing!, style: AppTextStyles.bodySm),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textTertiary),
        ],
      ),
      onTap: onTap,
    );
  }
}
