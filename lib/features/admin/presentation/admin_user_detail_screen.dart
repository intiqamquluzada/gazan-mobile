import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'admin_widgets.dart';

/// Support view of one account: contact, balance, latest coin movements.
class AdminUserDetailScreen extends ConsumerWidget {
  const AdminUserDetailScreen({super.key, required this.userId});

  final String userId;

  Future<void> _resetPassword(BuildContext context, WidgetRef ref) async {
    final bool? done = await showAdminResetPassword(context, userId);
    if (done == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(sProvider).passwordResetDone)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<AdminUserDetail> data =
        ref.watch(adminUserDetailProvider(userId));
    final DateFormat fmt = DateFormat('dd.MM.yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: Text(s.userDetailTitle)),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(title: s.notLoaded, subtitle: '$e'),
        data: (AdminUserDetail u) => ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(u.user.fullName.isEmpty ? s.unnamed : u.user.fullName,
                      style: AppTextStyles.h1),
                ),
                AdminRoleBadge(role: u.user.role),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(u.user.email, style: AppTextStyles.bodySm),
            if (u.user.phone != null)
              Text(u.user.phone!, style: AppTextStyles.bodySm),
            if (u.user.lastLoginAt != null)
              Text('${s.lastLoginLabel}: ${fmt.format(u.user.lastLoginAt!)}',
                  style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.lg),
            Text('${s.coinLabel}: ${u.coinBalance}', style: AppTextStyles.h3),
            Text('${s.loyaltyCard}: ${u.cardCount}', style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => _resetPassword(context, ref),
              icon: const Icon(Icons.lock_reset_rounded),
              label: Text(s.resetPasswordAction),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(s.recentTransactions, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            if (u.recentCoins.isEmpty)
              Text(s.noTransactions, style: AppTextStyles.bodySm),
            for (final AdminCoinLine l in u.recentCoins)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.amount > 0 ? '+${l.amount}' : '${l.amount}'),
                subtitle: Text(<String>[
                  if (l.companyName != null) l.companyName!,
                  if (l.note != null) l.note!,
                ].join(' · ')),
                trailing: l.createdAt == null
                    ? null
                    : Text(fmt.format(l.createdAt!),
                        style: AppTextStyles.caption),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lets an admin set a new password; returns true when it was changed.
Future<bool?> showAdminResetPassword(BuildContext context, String userId) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _ResetDialog(userId: userId),
  );
}

class _ResetDialog extends ConsumerStatefulWidget {
  const _ResetDialog({required this.userId});

  final String userId;

  @override
  ConsumerState<_ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends ConsumerState<_ResetDialog> {
  final TextEditingController _c = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final S s = ref.read(sProvider);
    if (_c.text.length < 8) {
      setState(() => _error = s.pwErrMin8);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .resetPassword(widget.userId, _c.text);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return AlertDialog(
      title: Text(s.resetPasswordAction),
      content: TextField(
        controller: _c,
        obscureText: true,
        decoration: InputDecoration(hintText: s.passwordHintMin8, labelText: s.password, errorText: _error),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(s.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _busy ? null : _save,
          child: Text(s.saveShort),
        ),
      ],
    );
  }
}
