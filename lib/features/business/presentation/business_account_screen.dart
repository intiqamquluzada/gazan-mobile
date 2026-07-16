import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../../profile/application/profile_settings_controller.dart';
import '../../profile/presentation/sheets/edit_profile_sheet.dart';
import '../../profile/presentation/sheets/language_sheet.dart';
import '../../profile/presentation/sheets/security_sheet.dart';
import '../../profile/presentation/sheets/theme_sheet.dart';

/// Personal account settings for a business owner — reached by tapping
/// the avatar on the business dashboard. Distinct from "Mənim biznesim"
/// (which edits the public company profile); this is where the owner
/// edits their own name/phone, changes their password, language, theme,
/// and signs out.
class BusinessAccountScreen extends ConsumerWidget {
  const BusinessAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppUser? user = ref.watch(currentUserProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final String language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.account)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: <Widget>[
                Avatar(name: user?.fullName ?? s.businessFallback, size: 56),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(user?.fullName ?? s.businessFallback,
                          style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '', style: AppTextStyles.bodySm),
                      if ((user?.phone ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(user!.phone!, style: AppTextStyles.bodySm),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(s.account, style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          _Tile(
            icon: Icons.person_outline_rounded,
            label: s.editProfile,
            trailing: s.nameAndPhone,
            onTap: () => _sheet(context, const EditProfileSheet()),
          ),
          _Tile(
            icon: Icons.lock_outline_rounded,
            label: s.security,
            trailing: s.password,
            onTap: () => _sheet(context, const SecuritySheet()),
          ),
          _Tile(
            icon: Icons.translate_rounded,
            label: s.language,
            trailing: _langLabel(language),
            onTap: () => _sheet(context, const LanguageSheet()),
          ),
          _Tile(
            icon: Icons.brightness_6_outlined,
            label: s.appearance,
            trailing: _themeLabel(s, themeMode),
            onTap: () => _sheet(context, const ThemeSheet()),
          ),

          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: Text(s.logout),
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final S s = ref.read(sProvider);
    final bool ok = await showConfirmSheet(
      context,
      title: s.logoutTitle,
      body: s.signOutBusinessBody,
      confirmLabel: s.logout,
      cancelLabel: s.stay,
    );
    if (ok) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  Future<void> _sheet(BuildContext context, Widget child) {
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
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label, style: AppTextStyles.bodyLg)),
                if (trailing != null)
                  Text(trailing!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
