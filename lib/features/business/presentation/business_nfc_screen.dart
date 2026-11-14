import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/nfc/nfc_reader.dart';
import '../../../core/platform/app_variant.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../nfc/data/nfc_admin_repository.dart';
import 'nfc_assign_sheet.dart';

/// Business → "NFC kartlar": the venue's own cards (block a lost one, tune
/// points per tap / cooldown / daily cap) and the tap log.
class BusinessNfcScreen extends ConsumerWidget {
  const BusinessNfcScreen({super.key});

  /// Read a physical card on the phone, then decide what it does.
  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final S s = ref.read(sProvider);
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(s.nfcHoldCard)));
    try {
      final NfcRead? read = await readOneNfcTag(alertMessage: s.nfcHoldCard);
      messenger.hideCurrentSnackBar();
      if (read == null) return;
      final String? token = read.token;
      if (token == null) {
        messenger.showSnackBar(SnackBar(content: Text(s.nfcNotOurCard)));
        return;
      }
      final NfcCard card = await container
          .read(nfcAdminRepositoryProvider)
          .identify(token: token, tagUid: read.uid.isEmpty ? null : read.uid);
      container.invalidate(myNfcCardsProvider);
      if (context.mounted) await showNfcAssignSheet(context, card);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.errorTryAgain)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.nfcCards),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: s.nfcCards),
              Tab(text: s.nfcTapLog),
            ],
          ),
        ),
        floatingActionButton: PlatformCaps.hasNfc
            ? FloatingActionButton.extended(
                onPressed: () => _scan(context, ref),
                icon: const Icon(Icons.nfc_rounded),
                label: Text(s.nfcScanCard),
              )
            : null,
        body: const TabBarView(
          children: <Widget>[_CardsTab(), _TapsTab()],
        ),
      ),
    );
  }
}

class _CardsTab extends ConsumerWidget {
  const _CardsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<NfcCard>> cards = ref.watch(myNfcCardsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myNfcCardsProvider),
      child: cards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ListView(children: <Widget>[
          EmptyState(title: s.notLoaded, subtitle: '$e'),
        ]),
        data: (List<NfcCard> list) {
          if (list.isEmpty) {
            return ListView(children: <Widget>[
              EmptyState(
                title: s.nfcCards,
                subtitle: s.nfcNoCardsBusiness,
                icon: Icons.nfc_rounded,
              ),
            ]);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, int i) => _CardTile(card: list[i]),
          );
        },
      ),
    );
  }
}

class _CardTile extends ConsumerWidget {
  const _CardTile({required this.card});

  final NfcCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    final bool active = card.isActive;

    Future<void> toggle() async {
      final ProviderContainer container =
          ProviderScope.containerOf(context, listen: false);
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      try {
        await container.read(nfcAdminRepositoryProvider).setStatus(
              card.id,
              active ? 'LOST' : 'ACTIVE',
              asAdmin: false,
            );
        container.invalidate(myNfcCardsProvider);
      } on ApiException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.message)));
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
            color: active ? p.border : AppColors.danger.withValues(alpha: 0.4)),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: card.isStamp
                      ? AppColors.caramelSoft
                      : AppColors.rewardSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  card.isStamp ? Icons.approval_rounded : Icons.toll_rounded,
                  color: card.isStamp ? AppColors.action : AppColors.onReward,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(card.label ?? nfcKindLabel(s, card.kind),
                        style: AppTextStyles.h3),
                    Text(
                      card.describe(s),
                      style: AppTextStyles.bodySm
                          .copyWith(color: p.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!active)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.dangerSoft,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(nfcStatusLabel(s, card.status),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.dangerText)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _Chip(label: '${s.nfcCooldown}: ${card.cooldownSec}'),
              _Chip(label: '${s.nfcDailyCap}: ${card.dailyCapPerUser}'),
              if (!card.isWritten) _Chip(label: s.nfcNotWritten, danger: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              TextButton.icon(
                onPressed: () => showNfcAssignSheet(context, card),
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: Text(s.nfcAssignAction),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: toggle,
                icon: Icon(
                    active ? Icons.block_rounded : Icons.lock_open_rounded,
                    size: 18,
                    color: active ? AppColors.dangerText : AppColors.successText),
                label: Text(active ? s.nfcBlock : s.nfcUnblock,
                    style: TextStyle(
                        color: active
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

class _TapsTab extends ConsumerWidget {
  const _TapsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<NfcTapLog>> taps = ref.watch(myNfcTapsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myNfcTapsProvider),
      child: taps.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ListView(
            children: <Widget>[EmptyState(title: s.notLoaded, subtitle: '$e')]),
        data: (List<NfcTapLog> list) {
          if (list.isEmpty) {
            return ListView(children: <Widget>[
              EmptyState(title: s.nfcTapLog, icon: Icons.nfc_rounded),
            ]);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: AppSpacing.lg),
            itemBuilder: (_, int i) => _TapRow(tap: list[i]),
          );
        },
      ),
    );
  }
}

class _TapRow extends ConsumerWidget {
  const _TapRow({required this.tap});

  final NfcTapLog tap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    final String when = tap.createdAt == null
        ? ''
        : '${tap.createdAt!.hour.toString().padLeft(2, '0')}:'
            '${tap.createdAt!.minute.toString().padLeft(2, '0')} · '
            '${tap.createdAt!.day}.${tap.createdAt!.month}';
    return Row(
      children: <Widget>[
        Icon(
          tap.accepted ? Icons.check_circle_rounded : Icons.block_rounded,
          size: 20,
          color: tap.accepted ? AppColors.success : AppColors.dangerText,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                tap.accepted
                    ? (tap.stampsDelta > 0
                        ? '+${tap.stampsDelta} ${s.stampWord}'
                        : '+${tap.pointsDelta}')
                    : nfcResultLabel(s, tap.result),
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              Text(when,
                  style:
                      AppTextStyles.caption.copyWith(color: p.textTertiary)),
            ],
          ),
        ),
        if (tap.suspicious)
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: AppColors.catCoffee),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.danger = false});

  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: danger ? p.dangerSoft : p.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(label,
          style: AppTextStyles.caption.copyWith(
              color: danger ? AppColors.dangerText : p.textSecondary)),
    );
  }
}
