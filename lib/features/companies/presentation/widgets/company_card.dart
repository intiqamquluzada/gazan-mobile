import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/location/device_location.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/company_logo.dart';
import '../../domain/company.dart';

/// Card used on the discover feed.
class CompanyCard extends ConsumerWidget {
  const CompanyCard({super.key, required this.company, required this.onTap});

  final Company company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final Color brand = Color(company.coverColorHex);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    // Prefer a live device→restaurant distance; fall back to whatever the
    // backend supplied (company.distanceKm).
    final ({double lat, double lng})? device =
        ref.watch(deviceLocationProvider).value;
    final double? distanceKm = distanceKmBetween(
          device: device,
          targetLat: company.latitude,
          targetLng: company.longitude,
        ) ??
        company.distanceKm;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: dark ? AppColors.borderDark : AppColors.border,
            ),
            boxShadow: dark ? null : AppShadows.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              CompanyLogo(
                name: company.name,
                brandColor: brand,
                imageUrl: company.logoUrl,
                size: 58,
                radius: AppRadius.lg,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            company.name,
                            style: AppTextStyles.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(AppIcons.star,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          company.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodySm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      company.tagline,
                      style: AppTextStyles.bodySm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        _Pill(
                          icon: company.category.icon,
                          label: company.category.labelOf(s),
                          tint: company.category.tint,
                        ),
                        if (distanceKm != null) ...<Widget>[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(AppIcons.location,
                              size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 2),
                          Text(
                            _fmtDistance(distanceKm),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "800 m" under 1 km, otherwise "1.2 km".
String _fmtDistance(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1)} km';
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.tint});

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: tint),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: tint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
