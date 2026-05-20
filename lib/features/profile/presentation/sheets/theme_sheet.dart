import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '_sheet_handle.dart';

class ThemeSheet extends ConsumerWidget {
  const ThemeSheet({super.key});

  static const List<_ThemeOption> _options = <_ThemeOption>[
    _ThemeOption(ThemeMode.light, 'Açıq', Icons.light_mode_rounded,
        'Həmişə açıq tema istifadə et'),
    _ThemeOption(ThemeMode.dark, 'Tünd', Icons.dark_mode_rounded,
        'Həmişə tünd tema istifadə et'),
    _ThemeOption(ThemeMode.system, 'Sistem', Icons.brightness_auto_rounded,
        'Cihaz parametrini izlə'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode current = ref.watch(themeModeProvider);
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
          Text('Görünüş', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.lg),
          for (final _ThemeOption o in _options)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () {
                  ref.read(themeModeProvider.notifier).setMode(o.mode);
                },
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: o.mode == current
                        ? AppColors.primarySoft
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: o.mode == current
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(o.icon, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(o.label, style: AppTextStyles.bodyLg),
                            Text(o.description,
                                style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                      if (o.mode == current)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeOption {
  const _ThemeOption(this.mode, this.label, this.icon, this.description);
  final ThemeMode mode;
  final String label;
  final IconData icon;
  final String description;
}
