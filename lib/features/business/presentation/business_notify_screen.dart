import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/panel_providers.dart';
import '../domain/panel_models.dart';

/// Owner → message to people holding a card at this venue. Each one goes to
/// an admin for approval before it is delivered.
class BusinessNotifyScreen extends ConsumerStatefulWidget {
  const BusinessNotifyScreen({super.key});

  @override
  ConsumerState<BusinessNotifyScreen> createState() => _NotifyState();
}

class _NotifyState extends ConsumerState<BusinessNotifyScreen> {
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
    final S s = ref.read(sProvider);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      messenger
          .showSnackBar(SnackBar(content: Text(s.titleAndBodyRequired)));
      return;
    }
    setState(() => _sending = true);
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    try {
      await container.read(panelRepositoryProvider).submitNotification(
            title: _title.text.trim(),
            body: _body.text.trim(),
          );
      _title.clear();
      _body.clear();
      container.invalidate(mySubmissionsProvider);
      messenger.showSnackBar(SnackBar(content: Text(s.notifySubmitted)));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<SubmittedNotification>> list =
        ref.watch(mySubmissionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.notifyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: <Widget>[
          Text(s.notifyHint, style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _title,
            maxLength: 160,
            decoration: InputDecoration(labelText: s.titleLabel),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _body,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: s.bodyLabel,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: _sending ? null : _send,
            child: Text(_sending ? s.sendingWord : s.notifySend),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(s.notifyMine, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          list.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, _) =>
                EmptyState(title: s.notLoaded, subtitle: '$e'),
            data: (List<SubmittedNotification> items) => items.isEmpty
                ? Text(s.noNotifSent, style: AppTextStyles.bodySm)
                : Column(
                    children: <Widget>[
                      for (final SubmittedNotification n in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(n.title),
                          subtitle: Text(n.body,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: _StatusChip(status: n.status),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends ConsumerWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final (String label, Color color) = switch (status) {
      'REJECTED' => (s.statusRejected, AppColors.dangerText),
      'PENDING' => (s.statusPending, AppColors.catCoffee),
      _ => (s.statusApproved, AppColors.successText),
    };
    return Text(label,
        style: AppTextStyles.caption
            .copyWith(color: color, fontWeight: FontWeight.w700));
  }
}
