import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../application/notifications_providers.dart';
import '../data/notifications_repository.dart';
import 'notification_detail_screen.dart';

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
    // Fetch afresh: a push may have arrived while the inbox was cached.
    ref
      ..invalidate(notificationInboxProvider)
      ..invalidate(unreadCountProvider);
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
          // Scrollable so pull-to-refresh works on these states too.
          error: (Object e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              const SizedBox(height: 120),
              ErrorState(error: e, onRetry: () => ref.invalidate(notificationInboxProvider)),
            ],
          ),
          data: (List<AppNotification> list) {
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext _, int i) {
                final AppNotification n = list[i];
                return _NotificationTile(
                  n: n,
                  ago: _ago(n.createdAt),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NotificationDetailScreen(notification: n),
                    ),
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

/// One inbox row: a two-line preview that opens the full notification.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.n,
    required this.ago,
    required this.onTap,
  });

  final AppNotification n;
  final String ago;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final BorderRadius radius = BorderRadius.circular(AppRadius.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: p.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Leading(imageUrl: n.imageUrl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              n.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyLg
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (!n.read)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: p.action,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm,
                      ),
                      const SizedBox(height: 6),
                      Text(ago, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 20, color: p.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Picture thumbnail when the notification has one, else the bell badge.
class _Leading extends StatelessWidget {
  const _Leading({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Widget bell = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.caramelSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(AppIcons.bell, size: 20, color: p.caramel),
    );
    if (imageUrl == null) return bell;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => bell,
        placeholder: (_, __) => ColoredBox(color: p.surfaceMuted),
      ),
    );
  }
}
