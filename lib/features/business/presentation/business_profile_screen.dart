import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/application/auth_controller.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/business_category.dart';
import '../../companies/domain/company.dart';
import '../../media/data/media_repository.dart';
import 'sheets/map_picker.dart';

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
  const _Amenity(this.code, this.icon);
  final String code;
  final IconData icon;
}

const List<_Amenity> _kAmenities = <_Amenity>[
  _Amenity('WIFI', Icons.wifi_rounded),
  _Amenity('WORKSPACE', Icons.laptop_mac_rounded),
  _Amenity('MEETING', Icons.groups_rounded),
  _Amenity('GARDEN', Icons.park_rounded),
  _Amenity('PARKING', Icons.local_parking_rounded),
  _Amenity('VEGAN', Icons.eco_rounded),
  _Amenity('PET', Icons.pets_rounded),
];

String _amenityLabel(S s, String code) {
  switch (code) {
    case 'WIFI':
      return s.amWifi;
    case 'WORKSPACE':
      return s.amWorkspace;
    case 'MEETING':
      return s.amMeeting;
    case 'GARDEN':
      return s.amGarden;
    case 'PARKING':
      return s.amParking;
    case 'VEGAN':
      return s.amVegan;
    case 'PET':
      return s.amPet;
    default:
      return code;
  }
}

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

  // Per-language overrides — optional. Empty value clears the
  // translation and the AZ default is used on read.
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _nameRu = TextEditingController();
  final TextEditingController _nameTr = TextEditingController();
  final TextEditingController _taglineEn = TextEditingController();
  final TextEditingController _taglineRu = TextEditingController();
  final TextEditingController _taglineTr = TextEditingController();
  bool _translationsExpanded = false;

  BusinessCategory _category = BusinessCategory.other;
  final Set<String> _amenities = <String>{};
  final List<String> _photoUrls = <String>[];
  String? _logoUrl;
  String? _companyId;
  final ImagePicker _picker = ImagePicker();
  bool _loaded = false;
  bool _saving = false;
  bool _uploadingPhoto = false;
  bool _uploadingLogo = false;

  void _hydrate(Company c) {
    if (_loaded) return;
    _loaded = true;
    _companyId = c.id;
    _name.text = c.name;
    _tagline.text = c.tagline;
    _address.text = c.address;
    _phone.text = c.phone ?? '';
    _instagram.text = c.instagram ?? '';
    _hours.text = c.workingHours ?? '';
    _menuUrl.text = c.menuUrl ?? '';
    _logoUrl = c.logoUrl;
    _photoUrls
      ..clear()
      ..addAll(c.photoUrls);
    _lat.text = c.latitude?.toString() ?? '';
    _lng.text = c.longitude?.toString() ?? '';
    _coinRate.text = c.coinRate?.toString() ?? '';
    _nameEn.text = c.nameEn ?? '';
    _nameRu.text = c.nameRu ?? '';
    _nameTr.text = c.nameTr ?? '';
    _taglineEn.text = c.taglineEn ?? '';
    _taglineRu.text = c.taglineRu ?? '';
    _taglineTr.text = c.taglineTr ?? '';
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
      _nameEn, _nameRu, _nameTr,
      _taglineEn, _taglineRu, _taglineTr,
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
        'logoUrl': _logoUrl ?? '',
        if (double.tryParse(_lat.text.trim()) != null)
          'latitude': double.parse(_lat.text.trim()),
        if (double.tryParse(_lng.text.trim()) != null)
          'longitude': double.parse(_lng.text.trim()),
        if (double.tryParse(_coinRate.text.trim()) != null)
          'coinRate': double.parse(_coinRate.text.trim()),
        // Translations: always sent so an emptied field clears the
        // override back to the AZ default on the server.
        'nameEn': _nameEn.text.trim(),
        'nameRu': _nameRu.text.trim(),
        'nameTr': _nameTr.text.trim(),
        'taglineEn': _taglineEn.text.trim(),
        'taglineRu': _taglineRu.text.trim(),
        'taglineTr': _taglineTr.text.trim(),
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
        SnackBar(content: Text(ref.read(sProvider).businessProfileUpdated)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ref.read(sProvider).error}: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Opens the interactive map picker and writes the chosen coordinates
  /// straight into the lat/lng fields.
  Future<void> _pickOnMap() async {
    final ({double lat, double lng})? result = await pickLocationOnMap(
      context,
      initialLat: double.tryParse(_lat.text.trim()),
      initialLng: double.tryParse(_lng.text.trim()),
    );
    if (result == null) return;
    setState(() {
      _lat.text = result.lat.toStringAsFixed(6);
      _lng.text = result.lng.toStringAsFixed(6);
    });
  }

  Future<void> _pickAndUpload() async {
    List<XFile> picked;
    try {
      picked = await _picker.pickMultiImage(imageQuality: 82);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.read(sProvider).photoNotPicked}: $e')),
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
      // Auto-save: persist the new gallery immediately so the change
      // sticks even if the owner doesn't press "Yadda saxla".
      await _autoSave(<String, dynamic>{
        'photoUrls': _photoUrls.join('\n'),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(sProvider).photosSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${ref.read(sProvider).photoNotUploaded}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _pickLogo() async {
    XFile? x;
    try {
      x = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.read(sProvider).photoNotPicked}: $e')),
        );
      }
      return;
    }
    if (x == null) return;
    setState(() => _uploadingLogo = true);
    try {
      final Uint8List bytes = await x.readAsBytes();
      final String url = await ref.read(mediaRepositoryProvider).uploadImage(
            bytes: bytes,
            filename: x.name.isEmpty ? 'logo.jpg' : x.name,
            contentType: x.mimeType ?? _guessType(x.name),
          );
      if (mounted) setState(() => _logoUrl = url);
      // Auto-save: persist the new logo immediately.
      await _autoSave(<String, dynamic>{'logoUrl': url});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(sProvider).logoUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.read(sProvider).logoNotUploaded}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  /// Persists a single-field change without requiring "Yadda saxla".
  /// Used for image uploads so the user never wonders whether the
  /// change was saved.
  Future<void> _autoSave(Map<String, dynamic> patch) async {
    final String? id = _companyId;
    if (id == null) return;
    await ref.read(companiesRepositoryProvider).updateCompany(id, patch);
    ref.invalidate(myCompanyProvider);
    ref.invalidate(companyByIdProvider(id));
    ref.invalidate(companiesProvider);
    ref.invalidate(featuredCompaniesProvider);
  }

  String _guessType(String name) {
    final String n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> _confirmSignOut() async {
    final S s = ref.read(sProvider);
    final bool ok = await showConfirmSheet(
      context,
      title: s.logoutTitle,
      body: s.signOutBusinessBody,
      confirmLabel: s.logout,
      cancelLabel: s.stay,
    );
    if (ok) {
      // Router's auth refresh listener redirects to the role picker.
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<Company?> async = ref.watch(myCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.myBusiness),
        actions: <Widget>[
          IconButton(
            tooltip: s.logout,
            icon: const Icon(AppIcons.logout),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: s.error,
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
              _section(s.sectionProfilePhoto),
              Row(
                children: <Widget>[
                  _LogoPreview(url: _logoUrl, name: _name.text),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          s.logoHint,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: <Widget>[
                            OutlinedButton.icon(
                              onPressed:
                                  _uploadingLogo ? null : _pickLogo,
                              icon: _uploadingLogo
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(AppIcons.camera, size: 18),
                              label: Text(_logoUrl == null
                                  ? s.uploadLogo
                                  : s.change),
                            ),
                            if (_logoUrl != null) ...<Widget>[
                              const SizedBox(width: AppSpacing.sm),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _logoUrl = null),
                                child: Text(s.delete),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section(s.sectionBasicInfo),
              AppTextField(label: s.name, controller: _name),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(label: s.taglineLabel, controller: _tagline),
              const SizedBox(height: AppSpacing.lg),
              Text(s.category,
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
                          child: Text(c.labelOf(s)),
                        ))
                    .toList(),
                onChanged: (BusinessCategory? v) =>
                    setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section(s.sectionContactHours),
              AppTextField(
                label: s.address,
                controller: _address,
                prefixIcon: AppIcons.location,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: s.workingHours,
                hint: s.workingHoursHint,
                controller: _hours,
                prefixIcon: AppIcons.clock,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: s.phone,
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Instagram',
                hint: s.instagramHint,
                controller: _instagram,
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section(s.sectionLocationMap),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickOnMap,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text(s.pickOnMap),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppTextField(
                      label: s.latitude,
                      controller: _lat,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: s.longitude,
                      controller: _lng,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section(s.sectionAmenities),
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
                          Text(_amenityLabel(s, a.code),
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

              _section(s.sectionPhotoMenu),
              Text(
                s.businessPhotosHint,
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
                label: s.menuLink,
                hint: s.menuLinkHint,
                controller: _menuUrl,
              ),
              const SizedBox(height: AppSpacing.xxl),

              _section(s.sectionCoinSystem),
              AppTextField(
                label: s.coinRate,
                hint: s.coinRateHint,
                controller: _coinRate,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                prefixIcon: AppIcons.token,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                s.coinRateNote,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Translations (optional) ──────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: _translationsExpanded,
                    onExpansionChanged: (bool v) =>
                        setState(() => _translationsExpanded = v),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    title: Text(s.translationsOptional,
                        style: AppTextStyles.h3),
                    subtitle: Text(
                      s.translationsHint,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    children: <Widget>[
                      AppTextField(label: s.nameEn, controller: _nameEn),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                          label: s.taglineEn, controller: _taglineEn),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(label: s.nameRu, controller: _nameRu),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                          label: s.taglineRu, controller: _taglineRu),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(label: s.nameTr, controller: _nameTr),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                          label: s.taglineTr, controller: _taglineTr),
                    ],
                  ),
                ),
              ),
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
    final S s = ref.read(sProvider);
    if (_name.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.enterBusinessName)),
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
        SnackBar(content: Text(s.businessCreated)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${s.error}: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
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
        Text(s.createYourBusiness, style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.xs),
        Text(
          s.createBusinessHint,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppTextField(label: s.businessName, controller: _name),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(label: s.taglineLabel, controller: _tagline),
        const SizedBox(height: AppSpacing.lg),
        Text(s.categoryLabel,
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
                    child: Text(c.labelOf(s)),
                  ))
              .toList(),
          onChanged: (BusinessCategory? v) =>
              setState(() => _category = v ?? _category),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: s.address,
          controller: _address,
          prefixIcon: AppIcons.location,
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: s.createBusiness,
          icon: AppIcons.store,
          loading: _busy,
          onPressed: _busy ? null : _create,
        ),
      ],
    );
  }
}

/// Owner-managed reward catalog: "100 coin → San Sebastian".
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
class _AddPhotoTile extends ConsumerWidget {
  const _AddPhotoTile({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(AppIcons.camera, color: AppColors.primary),
                  const SizedBox(height: 4),
                  Text(s.addPhoto,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.primary)),
                ],
              ),
      ),
    );
  }
}

/// Circular logo preview shown in the editor.
class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    const double s = 72;
    if (url == null || url!.isEmpty) {
      return Container(
        width: s,
        height: s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(AppIcons.store, color: AppColors.primary, size: 30),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: s,
        height: s,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: s,
          height: s,
          color: AppColors.surfaceAlt,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: s,
          height: s,
          color: AppColors.surfaceAlt,
          alignment: Alignment.center,
          child:
              const Icon(AppIcons.error, color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
