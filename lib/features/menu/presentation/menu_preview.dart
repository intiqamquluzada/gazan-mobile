import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../data/menu_repository.dart';

/// Inline menu on the venue page: category tabs + the first few items of
/// the selected category with prices, and a "full menu" action. Renders
/// nothing when the venue has no structured menu.
class MenuPreview extends ConsumerStatefulWidget {
  const MenuPreview({
    super.key,
    required this.companyId,
    required this.onOpenFull,
    this.currency = 'AZN',
  });

  final String companyId;

  /// Venue currency — prices are shown in it (₼ / ₺).
  final String currency;
  final void Function(List<MenuItem> items) onOpenFull;

  @override
  ConsumerState<MenuPreview> createState() => _MenuPreviewState();
}

class _MenuPreviewState extends ConsumerState<MenuPreview> {
  static const int _previewCount = 4;
  String? _category;

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final List<MenuItem> items =
        ref.watch(companyMenuProvider(widget.companyId)).valueOrNull ??
            const <MenuItem>[];
    if (items.isEmpty) return const SizedBox.shrink();

    final List<MenuItem> sorted = List<MenuItem>.of(items)
      ..sort((MenuItem a, MenuItem b) => a.sortOrder.compareTo(b.sortOrder));
    final List<String> categories = <String>[
      for (final MenuItem m in sorted) m.category,
    ].toSet().toList(growable: false);
    final String current =
        categories.contains(_category) ? _category! : categories.first;
    final List<MenuItem> visible = sorted
        .where((MenuItem m) => m.category == current)
        .take(_previewCount)
        .toList(growable: false);
    final AppPalette p = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.lg),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.restaurant_menu_rounded,
                  size: 20, color: AppColors.caramel),
              const SizedBox(width: AppSpacing.sm),
              Text(s.menuWord,
                  style: AppTextStyles.h3.copyWith(
                      color: context.palette.ink, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () => widget.onOpenFull(sorted),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('${s.fullMenu} (${items.length})',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
          if (categories.length > 1) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (BuildContext _, int i) {
                  final bool on = categories[i] == current;
                  return GestureDetector(
                    onTap: () => setState(() => _category = categories[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: on ? p.action : p.surfaceMuted,
                        gradient: on
                            ? const LinearGradient(
                                colors: AppColors.actionGradient)
                            : null,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        categories[i],
                        style: AppTextStyles.bodySm.copyWith(
                          color: on ? p.onAction : p.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          for (int i = 0; i < visible.length; i++) ...<Widget>[
            if (i > 0) Divider(height: AppSpacing.lg, color: p.divider),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _Row(item: visible[i], currency: widget.currency),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.currency});

  final MenuItem item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.name,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
              if ((item.description ?? '').isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  item.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(color: p.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (item.price != null) ...<Widget>[
          const SizedBox(width: AppSpacing.md),
          Text(
            Money.format(item.price!, currency),
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: p.caramelText,
            ),
          ),
        ],
      ],
    );
  }
}

