import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/notifications_providers.dart';
import '../data/notifications_repository.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Opening the inbox marks everything read.
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  Future<void> _markRead() async {
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
    } catch (_) {
      // Non-fatal — the badge will simply refresh next time.
    }
    if (!mounted) return;
    ref.invalidate(unreadCountProvider);
  }

  String _ago(DateTime? d) {
    if (d == null) return '';
    final S s = ref.read(sProvider);
    final Duration diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return s.nowWord;
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${s.minAgo}';
    if (diff.inHours < 24) return '${diff.inHours} ${s.hourAgo}';
    return '${diff.inDays} ${s.dayAgo}';
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<AppNotification>> async =
        ref.watch(notificationInboxProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.notifications)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationInboxProvider),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => EmptyState(
            title: s.notLoaded,
            subtitle: e.toString(),
            icon: AppIcons.error,
          ),
          data: (List<AppNotification> list) {
            if (list.isEmpty) {
              return ListView(
                children: <Widget>[
                  const SizedBox(height: 120),
                  EmptyState(
                    title: s.noNotifications,
                    subtitle: s.newNotifsHere,
                    icon: AppIcons.bell,
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext _, int i) {
                final AppNotification n = list[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.caramelSoft,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(AppIcons.bell,
                            size: 18, color: AppColors.action),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(n.title,
                                      style: AppTextStyles.bodyLg.copyWith(
                                          fontWeight: FontWeight.w700)),
                                ),
                                if (!n.read)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.action,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(n.body, style: AppTextStyles.bodySm),
                            const SizedBox(height: 6),
                            Text(_ago(n.createdAt),
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
