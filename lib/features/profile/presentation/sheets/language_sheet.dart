import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/profile_settings_controller.dart';
import '_sheet_handle.dart';

class LanguageSheet extends ConsumerWidget {
  const LanguageSheet({super.key});

  static const List<_Lang> _options = <_Lang>[
    _Lang('az', 'Azərbaycanca', '🇦🇿'),
    _Lang('en', 'English', '🇬🇧'),
    _Lang('ru', 'Русский', '🇷🇺'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String selected = ref.watch(languageProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SheetHandle(),
          const SizedBox(height: AppSpacing.lg),
          Text('Dil', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.lg),
          for (final _Lang l in _options)
            _LangTile(
              lang: l,
              selected: l.code == selected,
              onTap: () {
                ref.read(languageProvider.notifier).state = l.code;
                Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Qeyd: lokalizasiya tezliklə bütün ekranlara yayılacaq.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Lang {
  const _Lang(this.code, this.label, this.flag);
  final String code;
  final String label;
  final String flag;
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  final _Lang lang;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: <Widget>[
              Text(lang.flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(lang.label, style: AppTextStyles.bodyLg),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
