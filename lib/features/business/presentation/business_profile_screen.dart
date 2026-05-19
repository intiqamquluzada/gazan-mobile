import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final TextEditingController _photos = TextEditingController();
  final TextEditingController _lat = TextEditingController();
  final TextEditingController _lng = TextEditingController();

  BusinessCategory _category = BusinessCategory.other;
  final Set<String> _amenities = <String>{};
  bool _loaded = false;
  bool _saving = false;

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
    _photos.text = c.photoUrls.join('\n');
    _lat.text = c.latitude?.toString() ?? '';
    _lng.text = c.longitude?.toString() ?? '';
    _category = c.category;
    _amenities
      ..clear()
      ..addAll(c.amenities);
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _name, _tagline, _address, _phone, _instagram, _hours,
      _menuUrl, _photos, _lat, _lng,
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
        'photoUrls': _photos.text
            .split('\n')
            .map((String s) => s.trim())
            .where((String s) => s.isNotEmpty)
            .join('\n'),
        if (double.tryParse(_lat.text.trim()) != null)
          'latitude': double.parse(_lat.text.trim()),
        if (double.tryParse(_lng.text.trim()) != null)
          'longitude': double.parse(_lng.text.trim()),
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
            return const EmptyState(
              title: 'Biznes profili yoxdur',
              subtitle: 'Əvvəlcə biznesini yarat.',
              icon: AppIcons.store,
            );
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
              AppTextField(
                label: 'Foto linkləri (hər sətirdə bir)',
                hint: 'https://...jpg',
                controller: _photos,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Menyu linki',
                hint: 'https://... (PDF / sayt / şəkil)',
                controller: _menuUrl,
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
