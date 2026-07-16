import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/admin_promotions_repository.dart';

/// Admin CRUD for the Discover promotion banners ("reklamlar"): create,
/// edit, toggle active, delete — with a live preview of the banner.
class AdminPromotionsScreen extends ConsumerWidget {
  const AdminPromotionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<AdminPromotion>> async =
        ref.watch(adminPromotionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.promotions)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.newAd),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: s.notLoaded,
          subtitle: e.toString(),
          icon: AppIcons.error,
        ),
        data: (List<AdminPromotion> list) {
          if (list.isEmpty) {
            return EmptyState(
              title: s.noAdsYet,
              subtitle: s.createFirstBanner,
              icon: AppIcons.star,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminPromotionsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.huge),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.lg),
              itemBuilder: (BuildContext _, int i) => _PromoRow(
                promo: list[i],
                onEdit: () => _openForm(context, ref, existing: list[i]),
                onToggle: (bool v) => _toggle(context, ref, list[i], v),
                onDelete: () => _delete(context, ref, list[i]),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref,
      AdminPromotion p, bool active) async {
    try {
      await ref
          .read(adminPromotionsRepositoryProvider)
          .setActive(p.id, active);
      ref.invalidate(adminPromotionsProvider);
    } catch (e) {
      _snack(context, '${ref.read(sProvider).failed}: $e', error: true);
    }
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, AdminPromotion p) async {
    final S s = ref.read(sProvider);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(s.deleteAdTitle),
        content: Text('"${p.title}" ${s.willBeDeletedSuffix}'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminPromotionsRepositoryProvider).delete(p.id);
      ref.invalidate(adminPromotionsProvider);
    } catch (e) {
      if (context.mounted) _snack(context, '${s.deleteFailed}: $e', error: true);
    }
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref,
      {AdminPromotion? existing}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (BuildContext _) => _PromoForm(existing: existing),
    );
    ref.invalidate(adminPromotionsProvider);
  }

  void _snack(BuildContext context, String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : null,
    ));
  }
}

class _PromoRow extends ConsumerWidget {
  const _PromoRow({
    required this.promo,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final AdminPromotion promo;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _PromoPreview(promo: promo),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Switch(value: promo.active, onChanged: onToggle),
            Text(promo.active ? s.activeWord : s.inactiveWord,
                style: AppTextStyles.bodySm),
            const Spacer(),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: s.edit,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              tooltip: s.delete,
            ),
          ],
        ),
      ],
    );
  }
}

class _PromoPreview extends StatelessWidget {
  const _PromoPreview({required this.promo});

  final AdminPromotion promo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(promo.gradientStartHex),
            Color(promo.gradientEndHex),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: <Widget>[
          Text(promo.emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (promo.tag.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(promo.tag,
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white)),
                  ),
                const SizedBox(height: 4),
                Text(promo.title,
                    style: AppTextStyles.h3.copyWith(color: Colors.white)),
                if (promo.subtitle.isNotEmpty)
                  Text(promo.subtitle,
                      style: AppTextStyles.bodySm.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoForm extends ConsumerStatefulWidget {
  const _PromoForm({this.existing});

  final AdminPromotion? existing;

  @override
  ConsumerState<_PromoForm> createState() => _PromoFormState();
}

class _PromoFormState extends ConsumerState<_PromoForm> {
  late final TextEditingController _tag;
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  late final TextEditingController _emoji;
  late final TextEditingController _cta;
  int _startHex = 0xFF6C2BD9;
  int _endHex = 0xFF3D1486;
  bool _saving = false;

  static const List<({int start, int end})> _palettes =
      <({int start, int end})>[
    (start: 0xFF6C2BD9, end: 0xFF3D1486),
    (start: 0xFFE0356E, end: 0xFF8B1E4E),
    (start: 0xFF1FB46A, end: 0xFF0B7A46),
    (start: 0xFFF5A524, end: 0xFFB4740F),
    (start: 0xFF2D6CDF, end: 0xFF12408F),
  ];

  @override
  void initState() {
    super.initState();
    final AdminPromotion? p = widget.existing;
    _tag = TextEditingController(text: p?.tag ?? '');
    _title = TextEditingController(text: p?.title ?? '');
    _subtitle = TextEditingController(text: p?.subtitle ?? '');
    _emoji = TextEditingController(text: p?.emoji ?? '🎁');
    _cta = TextEditingController(text: p?.cta ?? 'Bax');
    if (p != null) {
      _startHex = p.gradientStartHex;
      _endHex = p.gradientEndHex;
    }
  }

  @override
  void dispose() {
    _tag.dispose();
    _title.dispose();
    _subtitle.dispose();
    _emoji.dispose();
    _cta.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _tag.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(sProvider).tagAndTitleRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final AdminPromotionsRepository repo =
          ref.read(adminPromotionsRepositoryProvider);
      if (widget.existing == null) {
        await repo.create(
          tag: _tag.text.trim(),
          title: _title.text.trim(),
          subtitle: _subtitle.text.trim(),
          emoji: _emoji.text.trim(),
          cta: _cta.text.trim(),
          gradientStartHex: _startHex,
          gradientEndHex: _endHex,
        );
      } else {
        await repo.update(widget.existing!.id, <String, dynamic>{
          'tag': _tag.text.trim(),
          'title': _title.text.trim(),
          'subtitle': _subtitle.text.trim(),
          'emoji': _emoji.text.trim(),
          'cta': _cta.text.trim(),
          'gradientStartHex': _startHex,
          'gradientEndHex': _endHex,
        });
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.read(sProvider).failed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final EdgeInsets bottom = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: bottom,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.existing == null ? s.newAd : s.editAd,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.lg),
            _PromoPreview(
              promo: AdminPromotion(
                id: '',
                tag: _tag.text,
                title: _title.text.isEmpty ? s.titleFallback : _title.text,
                subtitle: _subtitle.text,
                emoji: _emoji.text.isEmpty ? '🎁' : _emoji.text,
                gradientStartHex: _startHex,
                gradientEndHex: _endHex,
                cta: _cta.text,
                active: true,
                sortOrder: 0,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _tag,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: s.tagLabel,
                hintText: s.tagHint,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _title,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: s.titleLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _subtitle,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: s.subtitleLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _emoji,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(labelText: s.emojiLabel),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _cta,
                    decoration: InputDecoration(labelText: s.buttonTextLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(s.colorLabel, style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                for (final ({int start, int end}) p in _palettes)
                  GestureDetector(
                    onTap: () => setState(() {
                      _startHex = p.start;
                      _endHex = p.end;
                    }),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[Color(p.start), Color(p.end)],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: _startHex == p.start
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_saving
                  ? s.savingWord
                  : (widget.existing == null ? s.createAction : s.save)),
            ),
          ],
        ),
      ),
    );
  }
}
