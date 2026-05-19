import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/business_category.dart';
import '../../companies/domain/company.dart';
import '../../media/data/media_repository.dart';
import '../../wallet/application/wallet_providers.dart';
import '../../wallet/domain/coin_reward.dart';

/// "Mənim biznesim" — the owner manages every feature shown on the public
/// restaurant profile: details, hours, contact, location, amenities,
/// photos and menu link.
class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _Amenity {
  const _Amenity(this.code, this.label, this.icon);
  final String code;
  final String label;
  final IconData icon;
}

const List<_Amenity> _kAmenities = <_Amenity>[
  _Amenity('WIFI', 'Wifi', Icons.wifi_rounded),
  _Amenity('WORKSPACE', 'Çalışma', Icons.laptop_mac_rounded),
  _Amenity('MEETING', 'Toplantı', Icons.groups_rounded),
  _Amenity('GARDEN', 'Bağça', Icons.park_rounded),
  _Amenity('PARKING', 'Avtopark', Icons.local_parking_rounded),
  _Amenity('VEGAN', 'Vegan', Icons.eco_rounded),
  _Amenity('PET', 'Pet', Icons.pets_rounded),
];

class _BusinessProfileScreenState
    extends ConsumerState<BusinessProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _tagline = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _instagram = TextEditingController();
  final TextEditingController _hours = TextEditingController();
  final TextEditingController _menuUrl = TextEditingController();
  final TextEditingController _lat = TextEditingController();
  final TextEditingController _lng = TextEditingController();
  final TextEditingController _coinRate = TextEditingController();

  BusinessCategory _category = BusinessCategory.other;
  final Set<String> _amenities = <String>{};
  final List<String> _photoUrls = <String>[];
  final ImagePicker _picker = ImagePicker();
  bool _loaded = false;
  bool _saving = false;
  bool _uploadingPhoto = false;

  void _hydrate(Company c) {
    if (_loaded) return;
    _loaded = true;
    _name.text = c.name;
    _tagline.text = c.tagline;
    _address.text = c.address;
    _phone.text = c.phone ?? '';
    _instagram.text = c.instagram ?? '';
    _hours.text = c.workingHours ?? '';
    _menuUrl.text = c.menuUrl ?? '';
    _photoUrls
      ..clear()
      ..addAll(c.photoUrls);
    _lat.text = c.latitude?.toString() ?? '';
    _lng.text = c.longitude?.toString() ?? '';
    _coinRate.text = c.coinRate?.toString() ?? '';
    _category = c.category;
    _amenities
      ..clear()
      ..addAll(c.amenities);
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _name, _tagline, _address, _phone, _instagram, _hours,
      _menuUrl, _lat, _lng, _coinRate,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(Company company) async {
    setState(() => _saving = true);
    try {
      final Map<String, dynamic> patch = <String, dynamic>{
        'name': _name.text.trim(),
        'tagline': _tagline.text.trim(),
        'category': _category.wire,
        'address': _address.text.trim(),
        'phone': _phone.text.trim(),
        'instagram': _instagram.text.trim(),
        'workingHours': _hours.text.trim(),
        'menuUrl': _menuUrl.text.trim(),
        'amenities': _amenities.join(','),
        'photoUrls': _photoUrls.join('\n'),
        if (double.tryParse(_lat.text.trim()) != null)
          'latitude': double.parse(_lat.text.trim()),
        if (double.tryParse(_lng.text.trim()) != null)
          'longitude': double.parse(_lng.text.trim()),
        if (double.tryParse(_coinRate.text.trim()) != null)
          'coinRate': double.parse(_coinRate.text.trim()),
      };
      await ref
          .read(companiesRepositoryProvider)
          .updateCompany(company.id, patch);
      ref.invalidate(myCompanyProvider);
      ref.invalidate(companyByIdProvider(company.id));
      ref.invalidate(companiesProvider);
      ref.invalidate(featuredCompaniesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biznes profili yeniləndi ✓')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xəta: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUpload() async {
    List<XFile> picked;
    try {
      picked = await _picker.pickMultiImage(imageQuality: 82);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şəkil seçilmədi: $e')),
        );
      }
      return;
    }
    if (picked.isEmpty) return;
    setState(() => _uploadingPhoto = true);
    try {
      for (final XFile x in picked) {
        final Uint8List bytes = await x.readAsBytes();
        final String url =
            await ref.read(mediaRepositoryProvider).uploadImage(
                  bytes: bytes,
                  filename: x.name.isEmpty ? 'photo.jpg' : x.name,
                  contentType: x.mimeType ?? _guessType(x.name),
                );
        if (mounted) setState(() => _photoUrls.add(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şəkil yüklənmədi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  String _guessType(String name) {
    final String n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Company?> async = ref.watch(myCompanyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mənim biznesim')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: 'Xəta',
          subtitle: e.toString(),
          icon: AppIcons.error,
        ),
        data: (Company? company) {
          if (company == null) {
            return const _CreateBusinessForm();
          }
          _hydrate(company);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.huge,
            ),
            children: <Widget>[
              _section('Əsas məlumat'),
              AppTextField(label: 'Ad', controller: _name),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(label: 'Şüar / qısa təsvir', controller: _tagline),
              const SizedBox(height: AppSpacing.lg),
              Text('Kateqoriya',
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<BusinessCategory>(
                initialValue: _category,
                items: BusinessCategory.values
                    .map((BusinessCategory c) => DropdownMenuItem<
                            BusinessCategory>(
                          value: c,
                          child: Text(c.label),
                        ))
                    .toList(),
                onChanged: (BusinessCategory? v) =>
                    setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section('Əlaqə & saatlar'),
              AppTextField(
                label: 'Ünvan',
                controller: _address,
                prefixIcon: AppIcons.location,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'İş saatları',
                hint: 'məs. 09:00 – 23:00',
                controller: _hours,
                prefixIcon: AppIcons.clock,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Telefon',
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Instagram',
                hint: '@hesab',
                controller: _instagram,
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section('Yer (xəritə)'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppTextField(
                      label: 'Enlik (lat)',
                      controller: _lat,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Uzunluq (lng)',
                      controller: _lng,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section('İmkanlar'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _kAmenities.map((_Amenity a) {
                  final bool on = _amenities.contains(a.code);
                  return GestureDetector(
                    onTap: () => setState(() {
                      on
                          ? _amenities.remove(a.code)
                          : _amenities.add(a.code);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: on
                            ? AppColors.primarySoft
                            : AppColors.surfaceAlt,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: on
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(a.icon,
                              size: 18,
                              color: on
                                  ? AppColors.primary
                                  : AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Text(a.label,
                              style: AppTextStyles.bodySm.copyWith(
                                color: on
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: on
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section('Foto & menyu'),
              Text(
                'Biznes şəkilləri — telefon/kompüterindən yüklə '
                '(profil və axtarış səhifəsində görünür).',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (int i = 0; i < _photoUrls.length; i++)
                    _PhotoThumb(
                      url: _photoUrls[i],
                      onRemove: () =>
                          setState(() => _photoUrls.removeAt(i)),
                    ),
                  _AddPhotoTile(
                    loading: _uploadingPhoto,
                    onTap: _uploadingPhoto ? null : _pickAndUpload,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Menyu linki',
                hint: 'https://... (PDF / sayt / şəkil)',
                controller: _menuUrl,
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section('Coin sistemi'),
              AppTextField(
                label: 'Coin dərəcəsi (1 ₼ üçün neçə coin)',
                hint: 'məs. 0.1  → 1000 ₼ = 100 coin',
                controller: _coinRate,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                prefixIcon: AppIcons.token,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Kassir skan edəndə çek məbləğini yazır — coin avtomatik hesablanır.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _RewardCatalog(companyId: company.id),
              const SizedBox(height: AppSpacing.xxl),

              PrimaryButton(
                label: 'Yadda saxla',
                icon: AppIcons.check,
                loading: _saving,
                onPressed: _saving ? null : () => _save(company),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(t, style: AppTextStyles.h3),
      );
}

/// Shown when the signed-in owner has no business yet — lets them
/// bootstrap one (POST /api/v1/companies). After creation the parent
/// re-reads myCompany and the full editor appears.
class _CreateBusinessForm extends ConsumerStatefulWidget {
  const _CreateBusinessForm();

  @override
  ConsumerState<_CreateBusinessForm> createState() =>
      _CreateBusinessFormState();
}

class _CreateBusinessFormState extends ConsumerState<_CreateBusinessForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _tagline = TextEditingController();
  final TextEditingController _address = TextEditingController();
  BusinessCategory _category = BusinessCategory.coffee;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _tagline.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_name.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biznes adını yaz (ən az 2 hərf)')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(companiesRepositoryProvider).createCompany(
        <String, dynamic>{
          'name': _name.text.trim(),
          'tagline': _tagline.text.trim(),
          'category': _category.wire,
          'address': _address.text.trim(),
          'coverColorHex': 0xFF6C2BD9,
        },
      );
      ref.invalidate(myCompanyProvider);
      ref.invalidate(companiesProvider);
      ref.invalidate(featuredCompaniesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biznes yaradıldı ✓ İndi profili tamamla')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xəta: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.huge,
      ),
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(AppIcons.store,
              color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Biznesini yarat', style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bu hesabın hələ biznesi yoxdur. Aşağıdakıları doldur — '
          'sonra foto, menyu, imkanlar və s. əlavə edə bilərsən.',
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppTextField(label: 'Biznes adı', controller: _name),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(label: 'Şüar / qısa təsvir', controller: _tagline),
        const SizedBox(height: AppSpacing.lg),
        Text('Kateqoriya',
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<BusinessCategory>(
          initialValue: _category,
          items: BusinessCategory.values
              .map((BusinessCategory c) =>
                  DropdownMenuItem<BusinessCategory>(
                    value: c,
                    child: Text(c.label),
                  ))
              .toList(),
          onChanged: (BusinessCategory? v) =>
              setState(() => _category = v ?? _category),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Ünvan',
          controller: _address,
          prefixIcon: AppIcons.location,
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: 'Biznes yarat',
          icon: AppIcons.store,
          loading: _busy,
          onPressed: _busy ? null : _create,
        ),
      ],
    );
  }
}

/// Owner-managed reward catalog: "100 coin → San Sebastian".
class _RewardCatalog extends ConsumerWidget {
  const _RewardCatalog({required this.companyId});

  final String companyId;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final TextEditingController title = TextEditingController();
    final TextEditingController desc = TextEditingController();
    final TextEditingController cost = TextEditingController();
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Mükafat əlavə et'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: title,
                decoration: const InputDecoration(
                    hintText: 'Ad — məs. San Sebastian'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: desc,
                decoration:
                    const InputDecoration(hintText: 'Açıqlama (istəyə bağlı)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: cost,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Neçə coin',
                  prefixIcon: Icon(AppIcons.token),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Ləğv et'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Əlavə et'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final int? c = int.tryParse(cost.text.trim());
    if (title.text.trim().isEmpty || c == null || c <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad və düzgün coin məbləği yaz')),
        );
      }
      return;
    }
    try {
      await ref.read(walletRepositoryProvider).createReward(
            companyId: companyId,
            title: title.text.trim(),
            description:
                desc.text.trim().isEmpty ? null : desc.text.trim(),
            coinCost: c,
          );
      ref.invalidate(coinRewardsProvider(companyId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    }
  }

  Future<void> _delete(WidgetRef ref, CoinReward r) async {
    await ref.read(walletRepositoryProvider).deleteReward(r.id);
    ref.invalidate(coinRewardsProvider(companyId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CoinReward>> async =
        ref.watch(coinRewardsProvider(companyId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: Text('Mükafat kataloqu', style: AppTextStyles.h3)),
            TextButton.icon(
              onPressed: () => _add(context, ref),
              icon: const Icon(AppIcons.add, size: 18),
              label: const Text('Əlavə et'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object e, _) => Text('Xəta: $e',
              style: AppTextStyles.bodySm),
          data: (List<CoinReward> list) {
            if (list.isEmpty) {
              return Text(
                'Hələ mükafat yoxdur. "Əlavə et" ilə yarat — '
                'məs. 100 coin = 1 porsiya San Sebastian.',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            }
            return Column(
              children: <Widget>[
                for (final CoinReward r in list)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(AppIcons.token,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text('${r.coinCost}',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(r.title,
                                  style: AppTextStyles.bodyLg.copyWith(
                                      fontWeight: FontWeight.w700)),
                              if ((r.description ?? '').isNotEmpty)
                                Text(r.description!,
                                    style: AppTextStyles.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.error),
                          onPressed: () => _delete(ref, r),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// A square photo tile with a remove badge, used in the owner's gallery.
class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: CachedNetworkImage(
              imageUrl: url,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.surfaceAlt,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceAlt,
                alignment: Alignment.center,
                child: const Icon(AppIcons.error,
                    color: AppColors.textTertiary),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.close,
                    size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The "add photo" tile that opens the device picker and uploads.
class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(AppIcons.camera, color: AppColors.primary),
                  SizedBox(height: 4),
                  Text('Şəkil əlavə et',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.primary)),
                ],
              ),
      ),
    );
  }
}
