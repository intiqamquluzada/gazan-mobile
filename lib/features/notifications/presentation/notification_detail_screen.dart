import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../data/notifications_repository.dart';

/// Full view of one inbox notification: optional picture, title, exact date
/// and the complete (selectable) text, which the list only previews.
class NotificationDetailScreen extends ConsumerWidget {
  const NotificationDetailScreen({super.key, required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    final AppNotification n = notification;
    final DateTime? at = n.createdAt;
    final String? date =
        at == null ? null : DateFormat('d MMMM y, HH:mm', s.lang).format(at);

    return Scaffold(
      appBar: AppBar(title: Text(s.notifications)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl),
          children: <Widget>[
            if (n.imageUrl != null) ...<Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: n.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(color: p.surfaceMuted),
                    // A broken link should not leave an empty frame.
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: p.surfaceMuted,
                      child: Icon(Icons.image_not_supported_outlined,
                          color: p.textTertiary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ] else ...<Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.caramelSoft,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(AppIcons.bell, size: 24, color: p.caramel),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              n.title,
              style: AppTextStyles.h1.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            if (date != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Icon(Icons.schedule_rounded, size: 16, color: p.textTertiary),
                  const SizedBox(width: 6),
                  Text(date, style: AppTextStyles.caption),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: p.divider),
            const SizedBox(height: AppSpacing.lg),
            SelectableText(
              n.body,
              style: AppTextStyles.bodyLg.copyWith(
                color: p.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
