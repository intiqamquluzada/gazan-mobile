import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '_sheet_handle.dart';
import '../../../../core/theme/app_colors.dart';

class HelpSheet extends ConsumerWidget {
  const HelpSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final List<_FAQ> items = <_FAQ>[
      _FAQ(question: s.faqQ1, answer: s.faqA1),
      _FAQ(question: s.faqQ2, answer: s.faqA2),
      _FAQ(question: s.faqQ3, answer: s.faqA3),
      _FAQ(question: s.faqQ4, answer: s.faqA4),
      _FAQ(question: s.faqQ5, answer: s.faqA5),
      _FAQ(question: s.faqQ6, answer: s.faqA6),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SheetHandle(),
          const SizedBox(height: AppSpacing.lg),
          Text(s.faq, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.lg),
          for (final _FAQ f in items)
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: AppColors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(
                  bottom: AppSpacing.md,
                ),
                title: Text(f.question, style: AppTextStyles.bodyLg),
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(f.answer, style: AppTextStyles.bodySm),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.close),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQ {
  const _FAQ({required this.question, required this.answer});
  final String question;
  final String answer;
}
