import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../notifications/application/notifications_providers.dart';
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

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String t = _title.text.trim();
    final String b = _body.text.trim();
    if (t.isEmpty || b.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlıq və mətn yaz')),
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
          const SnackBar(content: Text('Bildiriş hər kəsə göndərildi ✓')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Göndərilmədi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AppNotification>> sent =
        ref.watch(adminSentProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.huge),
          children: <Widget>[
            Text('Bildiriş göndər', style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Bütün istifadəçilərə çatacaq və onların bildiriş '
              'qutusunda görünəcək.',
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _title,
              maxLength: 160,
              decoration: InputDecoration(
                labelText: 'Başlıq',
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
                labelText: 'Mətn',
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
                label: Text(_sending ? 'Göndərilir...' : 'Hamısına göndər'),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Göndərilənlər', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            sent.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object e, _) =>
                  Text('Xəta: $e', style: AppTextStyles.bodySm),
              data: (List<AppNotification> list) {
                if (list.isEmpty) {
                  return Text(
                    'Hələ bildiriş göndərilməyib.',
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  );
                }
                return Column(
                  children: <Widget>[
                    for (final AppNotification n in list)
                      Container(
                        margin:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(n.title,
                                style: AppTextStyles.bodyLg.copyWith(
                                    fontWeight: FontWeight.w700)),
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
