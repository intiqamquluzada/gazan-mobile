import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/i18n/strings_panel2.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/admin_providers.dart';
import '../data/admin_promotions_repository.dart';
import '../domain/admin_models.dart';
import '../../media/data/media_repository.dart';

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

  Future<void> _toggle(BuildContext context, WidgetRef ref, AdminPromotion p,
      bool active) async {
    final S s = ref.read(sProvider);
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    try {
      await container
          .read(adminPromotionsRepositoryProvider)
          .setActive(p.id, active);
      container.invalidate(adminPromotionsProvider);
    } catch (e) {
      if (context.mounted) _snack(context, '${s.failed}: $e', error: true);
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
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerText,
                minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    try {
      await container.read(adminPromotionsRepositoryProvider).delete(p.id);
      container.invalidate(adminPromotionsProvider);
    } catch (e) {
      if (context.mounted)
        _snack(context, '${s.deleteFailed}: $e', error: true);
    }
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref,
      {AdminPromotion? existing}) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
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
      backgroundColor: error ? AppColors.danger : null,
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
                  color: AppColors.danger),
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
    final String? photo = promo.imageUrl;
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
        image: photo == null
            ? null
            : DecorationImage(
                image: CachedNetworkImageProvider(photo),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppColors.media.withValues(alpha: 0.45),
                  BlendMode.darken,
                ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.onDark.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(promo.tag,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.onDark)),
                  ),
                const SizedBox(height: 4),
                Text(promo.title,
                    style: AppTextStyles.h3.copyWith(color: AppColors.onDark)),
                if (promo.subtitle.isNotEmpty)
                  Text(promo.subtitle,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onDark.withValues(alpha: 0.9),
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
  int _startHex = 0xFF9C7556;
  int _endHex = 0xFF7A5439;
  late final TextEditingController _image;
  bool _uploading = false;
  bool _saving = false;
  String? _companyId;
  DateTime? _endsAt;

  Future<void> _pickEnd() async {
    final S s = ref.read(sProvider);
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endsAt ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
      cancelText: s.cancel,
      confirmText: s.selectAction,
    );
    if (picked != null) {
      setState(() => _endsAt =
          DateTime(picked.year, picked.month, picked.day, 23, 59, 59));
    }
  }

  static const List<({int start, int end})> _palettes =
      <({int start, int end})>[
    (start: 0xFF9C7556, end: 0xFF7A5439), // coffee
    (start: 0xFFB0304A, end: 0xFF7A1F33), // rose
    (start: 0xFF4F6B4A, end: 0xFF33472F), // olive
    (start: 0xFFE0B26A, end: 0xFFA67C5B), // gold → caramel
    (start: 0xFF2F6F8A, end: 0xFF1E4A5C), // teal
  ];

  @override
  void initState() {
    super.initState();
    final AdminPromotion? p = widget.existing;
    _tag = TextEditingController(text: p?.tag ?? '');
    _title = TextEditingController(text: p?.title ?? '');
    _subtitle = TextEditingController(text: p?.subtitle ?? '');
    _emoji = TextEditingController(text: p?.emoji ?? '🎁');
    _cta = TextEditingController(
        text: p?.cta ?? ref.read(sProvider).pPromoCtaDefault);
    _image = TextEditingController(text: p?.imageUrl ?? '');
    _companyId = p?.companyId;
    _endsAt = p?.endsAt;
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
    _image.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? x = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    if (x == null) return;
    setState(() => _uploading = true);
    try {
      final Uint8List bytes = await x.readAsBytes();
      final String url = await ref.read(mediaRepositoryProvider).uploadImage(
            bytes: bytes,
            filename: x.name.isEmpty ? 'promo.jpg' : x.name,
            contentType: x.mimeType ?? 'image/jpeg',
          );
      if (mounted) setState(() => _image.text = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.read(sProvider).failed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
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
          imageUrl: _image.text.trim(),
          companyId: _companyId,
          endsAt: _endsAt,
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
          // Empty string clears the photo (backend trims to null).
          'imageUrl': _image.text.trim(),
          'companyId': _companyId,
          'endsAt': _endsAt?.toUtc().toIso8601String(),
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
    // Admin list (every status), not the public approved-only one.
    final List<AdminCompany> companies =
        ref.watch(adminCompanyOptionsProvider).valueOrNull ??
            const <AdminCompany>[];
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
                imageUrl:
                    _image.text.trim().isEmpty ? null : _image.text.trim(),
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
            DropdownButtonFormField<String?>(
              // Rebuilt once the venue list arrives so an existing link shows.
              key: ValueKey<int>(companies.length),
              initialValue: companies.any((AdminCompany c) => c.id == _companyId)
                  ? _companyId
                  : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: s.promoCompany),
              items: <DropdownMenuItem<String?>>[
                DropdownMenuItem<String?>(child: Text(s.promoNoCompany)),
                for (final AdminCompany c in companies)
                  DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text(c.name, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (String? v) => setState(() => _companyId = v),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(s.promoEndsAt),
              subtitle: Text(_endsAt == null
                  ? s.programNoExpiry
                  : '${_endsAt!.day.toString().padLeft(2, '0')}.'
                      '${_endsAt!.month.toString().padLeft(2, '0')}.'
                      '${_endsAt!.year}'),
              trailing: _endsAt == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(() => _endsAt = null),
                    ),
              onTap: _pickEnd,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(s.adImageLabel, style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _image,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'https://…',
                      suffixIcon: _image.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => setState(() => _image.clear()),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filledTonal(
                  onPressed: _uploading ? null : _pickImage,
                  icon: _uploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.add_photo_alternate_outlined),
                  tooltip: s.uploadPhoto,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(s.adImageHint, style: AppTextStyles.caption),
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
                              ? AppColors.action
                              : AppColors.transparent,
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
