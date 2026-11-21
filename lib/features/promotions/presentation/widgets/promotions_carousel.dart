import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/company_logo.dart';
import '../../../companies/application/companies_providers.dart';
import '../../../companies/domain/company.dart';
import '../../application/promotions_providers.dart';
import '../../domain/promotion.dart';

/// Discover promo banners: full-bleed photo cards that snap one at a time,
/// with a slim page indicator underneath.
///
/// Background = the promo's own photo, else the linked venue's cover,
/// else a warm gradient from the admin colours. A left-to-right scrim keeps
/// the copy legible on any photo.
class PromotionsCarousel extends ConsumerStatefulWidget {
  const PromotionsCarousel({super.key});

  @override
  ConsumerState<PromotionsCarousel> createState() => _PromotionsCarouselState();
}

class _PromotionsCarouselState extends ConsumerState<PromotionsCarousel> {
  final PageController _pc = PageController(viewportFraction: 0.9);
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Promotion>> async = ref.watch(promotionsProvider);
    final List<Promotion> list = async.valueOrNull ?? const <Promotion>[];
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      children: <Widget>[
        SizedBox(
          height: 176,
          child: PageView.builder(
            controller: _pc,
            padEnds: false,
            itemCount: list.length,
            onPageChanged: (int i) => setState(() => _page = i),
            itemBuilder: (BuildContext _, int i) => Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? AppSpacing.xl : AppSpacing.sm,
                right: i == list.length - 1 ? AppSpacing.xl : 0,
              ),
              child: _PromoCard(promo: list[i]),
            ),
          ),
        ),
        if (list.length > 1) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _Dots(count: list.length, index: _page),
        ],
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? p.caramel : p.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
      ],
    );
  }
}

class _PromoCard extends ConsumerWidget {
  const _PromoCard({required this.promo});

  final Promotion promo;

  String? _countdown(S s) {
    if (promo.endsAt == null) return null;
    final Duration remaining = promo.endsAt!.difference(DateTime.now());
    if (remaining.isNegative) return null;
    if (remaining.inDays > 0) return '${remaining.inDays} ${s.daysLeftSuffix}';
    if (remaining.inHours > 0) {
      return '${remaining.inHours} ${s.hoursLeftSuffix}';
    }
    return '${remaining.inMinutes} ${s.minsLeftSuffix}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final String? countdown = _countdown(s);
    final Company? company = promo.companyId == null
        ? null
        : ref.watch(companyByIdProvider(promo.companyId!)).valueOrNull;
    final String? photo = promo.imageUrl ??
        ((company?.photoUrls.isNotEmpty ?? false)
            ? company!.photoUrls.first
            : null);
    // "Yeni" / "New" tags get the rare highlight colour.
    final bool isNew = RegExp(r'^(yeni|new|нов)', caseSensitive: false)
        .hasMatch(promo.tag.trim());

    final Widget fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(Color(promo.gradientStartHex), AppColors.caramel, 0.4)!,
            Color.lerp(
                Color(promo.gradientEndHex), AppColors.surfaceDark, 0.6)!,
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: promo.companyId == null
          ? null
          : () => context.push('/companies/${promo.companyId}'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.sm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (photo == null)
                fallback
              else
                CachedNetworkImage(
                  imageUrl: photo,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => fallback,
                  errorWidget: (_, __, ___) => fallback,
                ),
              // Legibility scrim: strong on the left where the copy sits,
              // fading out so the photo still shows on the right.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      AppColors.media.withValues(alpha: 0.72),
                      AppColors.media.withValues(alpha: 0.35),
                      AppColors.transparent,
                    ],
                    stops: const <double>[0, 0.55, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _Chip(
                          label: promo.tag,
                          bg: isNew
                              ? AppColors.highlightSoft
                              : AppColors.onDark.withValues(alpha: 0.2),
                          fg: isNew ? AppColors.highlight : AppColors.onDark,
                        ),
                        const Spacer(),
                        if (countdown != null)
                          _Chip(
                            icon: AppIcons.clock,
                            label: countdown,
                            bg: AppColors.media.withValues(alpha: 0.35),
                            fg: AppColors.onDark,
                          ),
                      ],
                    ),
                    const Spacer(),
                    FractionallySizedBox(
                      widthFactor: 0.72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            promo.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.onDark,
                              height: 1.15,
                            ),
                          ),
                          if (promo.subtitle.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              promo.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.onDarkMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        if (company != null) ...<Widget>[
                          Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              color: AppColors.onDark,
                              shape: BoxShape.circle,
                            ),
                            child: CompanyLogo(
                              name: company.name,
                              brandColor: Color(company.coverColorHex),
                              imageUrl: company.logoUrl,
                              size: 24,
                              radius: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              company.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.onDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ] else
                          const Spacer(),
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 7, 10, 7),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                promo.cta,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.action,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 16, color: AppColors.action),
                            ],
                          ),
                        ),
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });

  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
