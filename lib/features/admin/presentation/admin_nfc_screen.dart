import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/i18n/strings_panel2.dart';
import '../../../core/platform/app_variant.dart';
import '../../../core/nfc/nfc_payload.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_program.dart';
import '../../nfc/data/nfc_admin_repository.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';

/// Admin → NFC: the card inventory. Issue a card for a venue, write it onto
/// a blank tag, rotate its secret, block it, and watch the tap log for abuse.
class AdminNfcScreen extends ConsumerWidget {
  const AdminNfcScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.nfcCards),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/admin'),
          ),
          bottom: TabBar(tabs: <Widget>[
            Tab(text: s.nfcCards),
            Tab(text: s.nfcTapLog),
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _newCard(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: Text(s.nfcNewCard),
        ),
        body: const TabBarView(children: <Widget>[_Inventory(), _Taps()]),
      ),
    );
  }

  Future<void> _newCard(BuildContext context, WidgetRef ref) async {
    final NfcCard? created = await showModalBottomSheet<NfcCard>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const _NewCardSheet(),
    );
    if (created == null || !context.mounted) return;
    ProviderScope.containerOf(context, listen: false)
        .invalidate(adminNfcCardsProvider);
    await _writeFlow(context, created);
  }
}

/// Writes the card's token onto a blank tag (Android only). Elsewhere the
/// token is shown so it can be written with another device.
Future<void> _writeFlow(BuildContext context, NfcCard card) async {
  if (card.token == null) return;
  if (!PlatformCaps.canWriteNfc) {
    await showDialog<void>(
      context: context,
      builder: (_) => _TokenDialog(token: card.token!),
    );
    return;
  }
  final ProviderContainer container =
      ProviderScope.containerOf(context, listen: false);
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _WriteDialog(card: card),
  );
  container.invalidate(adminNfcCardsProvider);
}

/// Shows a freshly issued card token on devices that cannot write NFC.
class _TokenDialog extends ConsumerWidget {
  const _TokenDialog({required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return AlertDialog(
      title: Text(s.pNfcTokenTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(s.pNfcTokenBody, style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.md),
          SelectableText(token,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: token));
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(s.pCopied)));
            }
          },
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: Text(s.pCopy),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.close),
        ),
      ],
    );
  }
}

class _WriteDialog extends ConsumerStatefulWidget {
  const _WriteDialog({required this.card});

  final NfcCard card;

  @override
  ConsumerState<_WriteDialog> createState() => _WriteDialogState();
}

class _WriteDialogState extends ConsumerState<_WriteDialog> {
  String? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    unawaited(NfcManager.instance.stopSession().catchError((_) {}));
    super.dispose();
  }

  Future<void> _start() async {
    try {
      final S s = ref.read(sProvider);
      final NfcAdminRepository repo = ref.read(nfcAdminRepositoryProvider);
      await NfcManager.instance.startSession(
        pollingOptions: <NfcPollingOption>{NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          try {
            final NdefAndroid? ndef = NdefAndroid.from(tag);
            if (ndef == null || !ndef.isWritable) {
              if (mounted) setState(() => _error = s.nfcNotWritable);
              return;
            }
            await ndef.writeNdefMessage(
                NfcPayload.messageFor(widget.card.token!));
            await repo.markWritten(widget.card.id);
            await NfcManager.instance.stopSession();
            if (mounted) setState(() => _done = true);
          } catch (e) {
            if (mounted) setState(() => _error = errorText(s, e, fallback: s.failed));
          }
        },
      );
    } catch (e) {
      if (mounted) setState(() => _error = errorText(ref.read(sProvider), e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return AlertDialog(
      title: Text(_done ? s.nfcWritten : s.nfcWriteCard),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            _done ? Icons.check_circle_rounded : Icons.nfc_rounded,
            size: 56,
            color: _done ? AppColors.success : AppColors.caramel,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _error ?? (_done ? s.nfcWrittenBody : s.nfcWriteHold),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(
                color: _error != null ? AppColors.dangerText : null),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_done ? s.close : s.cancel),
        ),
      ],
    );
  }
}

class _Inventory extends ConsumerWidget {
  const _Inventory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<NfcCard>> cards = ref.watch(adminNfcCardsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminNfcCardsProvider),
      child: cards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ListView(
            children: <Widget>[ErrorState(error: e, onRetry: () => ref.invalidate(adminNfcCardsProvider))]),
        data: (List<NfcCard> list) {
          if (list.isEmpty) {
            return ListView(children: <Widget>[
              EmptyState(title: s.nfcCards, icon: Icons.nfc_rounded),
            ]);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 96),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, int i) => _AdminCardTile(card: list[i]),
          );
        },
      ),
    );
  }
}

class _AdminCardTile extends ConsumerWidget {
  const _AdminCardTile({required this.card});

  final NfcCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: card.isActive
              ? p.border
              : AppColors.danger.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(card.companyName,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
              Text(nfcKindLabel(s, card.kind),
                  style: AppTextStyles.caption
                      .copyWith(color: p.textSecondary)),
            ],
          ),
          Text(
            card.describe(s),
            style: AppTextStyles.bodySm.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: 4,
            children: <Widget>[
              if (!card.isActive)
                Text(nfcStatusLabel(s, card.status),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.dangerText)),
              if (!card.isWritten)
                Text(s.nfcNotWritten,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.dangerText)),
              if (card.tagUid != null)
                Text('UID ${card.tagUid}',
                    style: AppTextStyles.caption
                        .copyWith(color: p.textTertiary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              TextButton.icon(
                // A rotated token only works once written to the card, so
                // this needs a phone that can write.
                onPressed: !PlatformCaps.canWriteNfc
                    ? null
                    : () => _rotate(context, s),
                icon: const Icon(Icons.autorenew_rounded, size: 18),
                label: Text(s.nfcRotate),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _toggleStatus(context, s),
                icon: Icon(
                    card.isActive
                        ? Icons.block_rounded
                        : Icons.lock_open_rounded,
                    size: 18,
                    color: card.isActive
                        ? AppColors.dangerText
                        : AppColors.successText),
                label: Text(card.isActive ? s.nfcBlock : s.nfcUnblock,
                    style: TextStyle(
                        color: card.isActive
                            ? AppColors.dangerText
                            : AppColors.successText)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on _AdminCardTile {
  Future<void> _rotate(BuildContext context, S s) async {
    final bool ok = await showConfirmSheet(
      context,
      title: s.nfcRotate,
      body: s.pNfcRotateWarn,
      confirmLabel: s.nfcRotate,
      cancelLabel: s.cancel,
      icon: Icons.autorenew_rounded,
    );
    if (!ok || !context.mounted) return;
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final NfcCard fresh =
          await container.read(nfcAdminRepositoryProvider).rotate(card.id);
      container.invalidate(adminNfcCardsProvider);
      if (context.mounted) await _writeFlow(context, fresh);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text(errorText(s, e, fallback: s.failed)),
          backgroundColor: AppColors.danger));
    }
  }

  Future<void> _toggleStatus(BuildContext context, S s) async {
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await container
          .read(nfcAdminRepositoryProvider)
          .setStatus(card.id, card.isActive ? 'REVOKED' : 'ACTIVE');
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text(errorText(s, e, fallback: s.failed)),
          backgroundColor: AppColors.danger));
    } finally {
      container.invalidate(adminNfcCardsProvider);
    }
  }
}

/// Issue a card: venue + kind (+ campaign for stamp cards).
class _NewCardSheet extends ConsumerStatefulWidget {
  const _NewCardSheet();

  @override
  ConsumerState<_NewCardSheet> createState() => _NewCardSheetState();
}

class _NewCardSheetState extends ConsumerState<_NewCardSheet> {
  AdminCompany? _company;
  String _kind = 'UNASSIGNED';
  LoyaltyProgram? _program;
  final TextEditingController _label = TextEditingController();
  final TextEditingController _points = TextEditingController(text: '100');
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    _points.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final S s = ref.read(sProvider);
    if (_company == null || (_kind == 'STAMP' && _program == null)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.selectBusiness)));
      return;
    }
    setState(() => _saving = true);
    try {
      final NfcCard card = await ref.read(nfcAdminRepositoryProvider).create(
            companyId: _company!.id,
            kind: _kind,
            programId: _program?.id,
            label: _label.text.trim().isEmpty ? null : _label.text.trim(),
            pointsValue: int.tryParse(_points.text.trim()),
          );
      if (mounted) Navigator.of(context).pop(card);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorText(s, e, fallback: s.failed))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    // Admin list: includes pending venues, which still need their cards.
    final List<AdminCompany> companies =
        ref.watch(adminCompanyOptionsProvider).valueOrNull ??
            const <AdminCompany>[];
    final List<LoyaltyProgram> programs = _company == null
        ? const <LoyaltyProgram>[]
        : (ref.watch(programsForCompanyProvider(_company!.id)).valueOrNull ??
            const <LoyaltyProgram>[]);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: MediaQuery.viewInsetsOf(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(s.nfcNewCard, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _company?.id,
              isExpanded: true,
              decoration: InputDecoration(labelText: s.selectBusiness),
              items: companies
                  .map((AdminCompany c) => DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.name, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (String? id) => setState(() {
                _company = companies
                    .where((AdminCompany c) => c.id == id)
                    .firstOrNull;
                _program = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<String>(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(
                    value: 'UNASSIGNED', label: Text(s.nfcKindUnassigned)),
                ButtonSegment<String>(
                    value: 'STAMP', label: Text(s.nfcKindStamp)),
                ButtonSegment<String>(
                    value: 'POINTS', label: Text(s.nfcKindPoints)),
              ],
              selected: <String>{_kind},
              onSelectionChanged: (Set<String> v) =>
                  setState(() => _kind = v.first),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_kind == 'STAMP')
              DropdownButtonFormField<LoyaltyProgram>(
                initialValue: _program,
                decoration: InputDecoration(labelText: s.campaigns),
                items: programs
                    .map((LoyaltyProgram p) =>
                        DropdownMenuItem<LoyaltyProgram>(
                            value: p, child: Text(p.title)))
                    .toList(),
                onChanged: (LoyaltyProgram? p) => setState(() => _program = p),
              )
            else if (_kind == 'POINTS')
              TextField(
                controller: _points,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: s.hintNumber, labelText: s.nfcPointsPerTap),
              ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _label,
              decoration: InputDecoration(
                  labelText: s.name, hintText: s.nfcLabelHint),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(s.nfcWriteCard),
            ),
          ],
        ),
      ),
    );
  }
}

class _Taps extends ConsumerStatefulWidget {
  const _Taps();

  @override
  ConsumerState<_Taps> createState() => _TapsState();
}

class _TapsState extends ConsumerState<_Taps> {
  bool _suspiciousOnly = false;
  late Future<List<NfcTapLog>> _future = _load();

  Future<List<NfcTapLog>> _load() => ref
      .read(nfcAdminRepositoryProvider)
      .adminTaps(suspiciousOnly: _suspiciousOnly);

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
          child: Row(
            children: <Widget>[
              FilterChip(
                label: Text(s.nfcSuspiciousOnly),
                selected: _suspiciousOnly,
                onSelected: (bool v) => setState(() {
                  _suspiciousOnly = v;
                  _future = _load();
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<NfcTapLog>>(
            future: _future,
            builder: (_, AsyncSnapshot<List<NfcTapLog>> snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ListView(children: <Widget>[
                  ErrorState(error: snap.error!),
                ]);
              }
              final List<NfcTapLog> list = snap.data ?? const <NfcTapLog>[];
              if (list.isEmpty) {
                return ListView(children: <Widget>[
                  EmptyState(title: s.nfcTapLog, icon: Icons.nfc_rounded),
                ]);
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: AppSpacing.lg),
                itemBuilder: (_, int i) {
                  final NfcTapLog t = list[i];
                  return Row(
                    children: <Widget>[
                      Icon(
                        t.accepted
                            ? Icons.check_circle_rounded
                            : Icons.block_rounded,
                        size: 20,
                        color: t.accepted
                            ? AppColors.success
                            : AppColors.dangerText,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(nfcResultLabel(s, t.result),
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w600)),
                            Text(
                              <String>[
                                if (t.pointsDelta > 0) '+${t.pointsDelta}',
                                if (t.stampsDelta > 0) '+${t.stampsDelta} ●',
                                if (t.distanceM != null) '${t.distanceM} m',
                                if (t.note != null) t.note!,
                                if (t.createdAt != null) _stamp(t.createdAt!),
                              ].join(' · '),
                              style: AppTextStyles.caption
                                  .copyWith(color: p.textTertiary),
                            ),
                          ],
                        ),
                      ),
                      if (t.suspicious)
                        Icon(Icons.warning_amber_rounded,
                            size: 18, color: AppColors.catCoffee),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

String _stamp(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
}
