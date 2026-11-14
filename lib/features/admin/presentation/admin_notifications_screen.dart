import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../notifications/application/notifications_providers.dart';
import '../../business/domain/panel_models.dart';
import '../../notifications/data/notifications_repository.dart';

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends ConsumerState<AdminNotificationsScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  bool _sending = false;
  final Set<String> _deciding = <String>{};

  Future<void> _decide(SubmittedNotification n, bool approve) async {
    setState(() => _deciding.add(n.id));
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await container
          .read(notificationsRepositoryProvider)
          .adminDecide(n.id, approve: approve);
      container
        ..invalidate(adminPendingNotificationsProvider)
        ..invalidate(adminSentProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _deciding.remove(n.id));
    }
  }

  Widget _pendingSection(S s) {
    final List<SubmittedNotification> pending =
        ref.watch(adminPendingNotificationsProvider).valueOrNull ??
            const <SubmittedNotification>[];
    if (pending.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(s.pendingNotificationsLabel, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        for (final SubmittedNotification n in pending)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(n.title,
                      style: AppTextStyles.bodyLg
                          .copyWith(fontWeight: FontWeight.w700)),
                  Text(n.body, style: AppTextStyles.bodySm),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: _deciding.contains(n.id)
                            ? null
                            : () => _decide(n, false),
                        child: Text(s.rejectAction),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                        onPressed: _deciding.contains(n.id)
                            ? null
                            : () => _decide(n, true),
                        child: Text(s.approveAction),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final S s = ref.read(sProvider);
    final String t = _title.text.trim();
    final String b = _body.text.trim();
    if (t.isEmpty || b.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.titleAndBodyRequired)),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await ref
          .read(notificationsRepositoryProvider)
          .adminSend(title: t, body: b);
      _title.clear();
      _body.clear();
      ref.invalidate(adminSentProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.notifSentToAll)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${s.failed}: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<AppNotification>> sent = ref.watch(adminSentProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.huge),
          children: <Widget>[
            _pendingSection(s),
            Text(s.sendNotification, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              s.notifReachAll,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _title,
              maxLength: 160,
              decoration: InputDecoration(
                labelText: s.titleLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _body,
              maxLines: 4,
              maxLength: 2000,
              decoration: InputDecoration(
                labelText: s.bodyLabel,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(AppIcons.bell, size: 18),
                label: Text(_sending ? s.sendingWord : s.sendToAll),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(s.sentItems, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            sent.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object e, _) =>
                  Text('${s.error}: $e', style: AppTextStyles.bodySm),
              data: (List<AppNotification> list) {
                if (list.isEmpty) {
                  return Text(
                    s.noNotifSent,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  );
                }
                return Column(
                  children: <Widget>[
                    for (final AppNotification n in list)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(n.title,
                                style: AppTextStyles.bodyLg
                                    .copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(n.body, style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
