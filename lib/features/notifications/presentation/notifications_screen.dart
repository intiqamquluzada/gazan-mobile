import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final Duration diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'indi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dəq əvvəl';
    if (diff.inHours < 24) return '${diff.inHours} saat əvvəl';
    return '${diff.inDays} gün əvvəl';
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AppNotification>> async =
        ref.watch(notificationInboxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirişlər')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationInboxProvider),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => EmptyState(
            title: 'Yüklənmədi',
            subtitle: e.toString(),
            icon: AppIcons.error,
          ),
          data: (List<AppNotification> list) {
            if (list.isEmpty) {
              return ListView(
                children: const <Widget>[
                  SizedBox(height: 120),
                  EmptyState(
                    title: 'Bildiriş yoxdur',
                    subtitle: 'Yeni bildirişlər burada görünəcək.',
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
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(AppIcons.bell,
                            size: 18, color: AppColors.primary),
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
                                      color: AppColors.primary,
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
