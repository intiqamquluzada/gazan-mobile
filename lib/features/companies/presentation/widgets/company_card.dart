import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/location/device_location.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/company_logo.dart';
import '../../../favorites/application/favorites_providers.dart';
import '../../../promotions/application/promotions_providers.dart';
import '../../../promotions/domain/promotion.dart';
import '../../domain/company.dart';

// Card colours, all from the central tokens (see AppColors). The card is
// a white surface in both modes, so it reads the light token set.
const Color _kSurface = AppColors.surface;
const Color _kTitle = AppColors.textPrimary;
const Color _kSubtitle = AppColors.textSecondary;
const Color _kHeartBg = AppColors.dangerSoft;
const Color _kHeart = AppColors.danger;
const Color _kCta = AppColors.action;
const Color _kPillBg = AppColors.caramelSoft;
const Color _kPillText = AppColors.action;
const Color _kBadgeBg = AppColors.successSoft;
const Color _kBadgeText = AppColors.successText;
const Color _kOpenDot = AppColors.success;
const Color _kClosedDot = AppColors.textTertiary;
const Color _kDivider = AppColors.divider;
const Color _kFeatureIcon = AppColors.textPrimary;
const Color _kFeatureText = AppColors.textSecondary;
const Color _kFooterText = AppColors.textSecondary;
const Color _kLogoBorder = AppColors.border;

/// Venue card: cover photo + details, warm cream "premium café" look.
///
/// ≥768 dp wide it lays out horizontally (≈2.6:1, photo 40 % / content
/// 60 %, every size scaled from a 1440 px reference); narrower — i.e.
/// phones — it stacks vertically with a 16:9 photo and a 3×2 amenity
/// grid. Blocks with no data (hours, amenities, campaigns) are hidden.
class CompanyCard extends ConsumerWidget {
  const CompanyCard({super.key, required this.company, required this.onTap});

  final Company company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);

    final ({double lat, double lng})? device =
        ref.watch(deviceLocationProvider).value;
    final double? distanceKm = distanceKmBetween(
          device: device,
          targetLat: company.latitude,
          targetLng: company.longitude,
        ) ??
        company.distanceKm;

    final bool favorite = ref.watch(favoritesProvider).contains(company.id);
    final bool? open = _isOpenNow(company.workingHours, DateTime.now());
    final int campaigns =
        (ref.watch(promotionsProvider).valueOrNull ?? const <Promotion>[])
            .where((Promotion p) => p.companyId == company.id)
            .length;
    final List<_Feature> features = <_Feature>[
      for (final _Feature f in _Feature.all)
        if (company.amenities.contains(f.code)) f,
    ].take(6).toList(growable: false);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double width = c.maxWidth.clamp(0, 1440).toDouble();
        final bool wide = width >= 768;
        final _M m = wide ? _M.wide(width / 1440) : const _M.mobile();

        final Widget cover = _Cover(company: company, m: m, s: s);
        final Widget content = !wide
            ? const SizedBox.shrink()
            : _Content(
                company: company,
                m: m,
                wide: wide,
                s: s,
                favorite: favorite,
                onFavorite: () =>
                    ref.read(favoritesProvider.notifier).toggle(company.id),
                onCollect: onTap,
                open: open,
                campaigns: campaigns,
                features: features,
                distanceKm: distanceKm,
                innerWidth: width - m.pad * 2,
              );

        final Widget body = wide
            ? AspectRatio(
                aspectRatio: 1440 / 560,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(flex: 40, child: cover),
                    SizedBox(width: m.gap),
                    Expanded(flex: 60, child: content),
                  ],
                ),
              )
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(width: (width - m.pad * 2) * 0.36, child: cover),
                    SizedBox(width: m.gap),
                    Expanded(
                      child: _CompactContent(
                        company: company,
                        s: s,
                        favorite: favorite,
                        onFavorite: () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(company.id),
                        onCollect: onTap,
                        open: open,
                        campaigns: campaigns,
                        features: features,
                        distanceKm: distanceKm,
                      ),
                    ),
                  ],
                ),
              );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(m.radius),
                border: Border.all(color: AppColors.border),
                boxShadow: wide ? AppShadows.md : AppShadows.sm,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(m.radius),
                  child: Padding(padding: EdgeInsets.all(m.pad), child: body),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// All sizes for one layout. Wide values are the 1440 px spec × [k].
class _M {
  const _M({
    required this.pad,
    required this.radius,
    required this.imageRadius,
    required this.gap,
    required this.logo,
    required this.title,
    required this.subtitle,
    required this.heart,
    required this.heartIcon,
    required this.button,
    required this.buttonText,
    required this.pillText,
    required this.featureIcon,
    required this.featureText,
    required this.footerText,
    required this.footerIcon,
    required this.slogan,
    required this.coverName,
    required this.coverSub,
    required this.coverIcon,
    required this.rowGap,
  });

  factory _M.wide(double k) => _M(
        pad: 28 * k,
        radius: 32 * k,
        imageRadius: 24 * k,
        gap: 40 * k,
        logo: 140 * k,
        title: 44 * k,
        subtitle: 22 * k,
        heart: 72 * k,
        heartIcon: 34 * k,
        button: 64 * k,
        buttonText: 22 * k,
        pillText: 19 * k,
        featureIcon: 40 * k,
        featureText: 18 * k,
        footerText: 22 * k,
        footerIcon: 26 * k,
        slogan: 28 * k,
        coverName: 44 * k,
        coverSub: 15 * k,
        coverIcon: 56 * k,
        rowGap: 28 * k,
      );

  /// Phones: horizontal but compact (~150 dp tall). Only the card shell
  /// and the cover read these; the right column is [_CompactContent].
  const _M.mobile()
      : pad = 10,
        radius = 20,
        imageRadius = 14,
        gap = 11,
        logo = 60,
        title = 20,
        subtitle = 13,
        heart = 44,
        heartIcon = 21,
        button = 42,
        buttonText = 14,
        pillText = 12.5,
        featureIcon = 24,
        featureText = 11.5,
        footerText = 13,
        footerIcon = 17,
        slogan = 10,
        coverName = 11,
        coverSub = 0,
        coverIcon = 17,
        rowGap = 16;

  final double pad, radius, imageRadius, gap, logo, title, subtitle;
  final double heart, heartIcon, button, buttonText, pillText;
  final double featureIcon, featureText, footerText, footerIcon;
  final double slogan, coverName, coverSub, coverIcon, rowGap;
}

TextStyle _font(double size, FontWeight w, Color c,
        {double spacing = 0, double height = 1.25}) =>
    AppTextStyles.body.copyWith(
      fontSize: size,
      fontWeight: w,
      color: c,
      letterSpacing: spacing,
      height: height,
    );

// ─────────────────────────── Cover ───────────────────────────

class _Cover extends StatelessWidget {
  const _Cover({required this.company, required this.m, required this.s});

  final Company company;
  final _M m;
  final S s;

  @override
  Widget build(BuildContext context) {
    final Color brand = Color(company.coverColorHex);
    final Widget panel = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(brand, AppColors.caramel, 0.35)!,
            Color.lerp(brand, AppColors.surfaceDark, 0.45)!,
          ],
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(m.imageRadius),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (company.photoUrls.isEmpty)
            panel
          else
            CachedNetworkImage(
              imageUrl: company.photoUrls.first,
              fit: BoxFit.cover,
              placeholder: (_, __) => panel,
              errorWidget: (_, __, ___) => panel,
              imageBuilder: (_, ImageProvider img) => Semantics(
                image: true,
                label: company.name,
                child: Image(image: img, fit: BoxFit.cover),
              ),
            ),
          // Bottom scrim: transparent → rgba(0,0,0,.55)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: <double>[0.45, 1],
                colors: <Color>[AppColors.transparent, AppColors.scrim],
              ),
            ),
          ),
          // White wordmark, top-left — only on the colour panel; a real
          // photo already carries the venue's identity and text over it
          // just adds clutter.
          if (company.photoUrls.isEmpty)
            Positioned(
              left: m.pad,
              top: m.pad,
              right: m.pad,
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(company.category.icon,
                        size: m.coverIcon, color: AppColors.onDark),
                    SizedBox(height: m.coverIcon * 0.25),
                    Text(
                      company.name.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _font(
                          m.coverName, FontWeight.w300, AppColors.onDark,
                          spacing: m.coverName * 0.14, height: 1.1),
                    ),
                    if (m.coverSub > 0) ...<Widget>[
                      SizedBox(height: m.coverSub * 0.4),
                      Text(
                        company.category.labelOf(s).toUpperCase(),
                        style: _font(
                            m.coverSub, FontWeight.w500, AppColors.onDark,
                            spacing: m.coverSub * 0.3),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          // Slogan, bottom-centre
          if (company.tagline.isNotEmpty)
            Positioned(
              left: m.pad,
              right: m.pad,
              bottom: m.pad * 0.9,
              child: Text(
                company.tagline,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _font(m.slogan, FontWeight.w500, AppColors.onDark,
                    height: 1.2),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Content ───────────────────────────

class _Content extends StatelessWidget {
  const _Content({
    required this.company,
    required this.m,
    required this.wide,
    required this.s,
    required this.favorite,
    required this.onFavorite,
    required this.onCollect,
    required this.open,
    required this.campaigns,
    required this.features,
    required this.distanceKm,
    required this.innerWidth,
  });

  final Company company;
  final _M m;
  final bool wide;
  final S s;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onCollect;
  final bool? open;
  final int campaigns;
  final List<_Feature> features;
  final double? distanceKm;
  final double innerWidth;

  @override
  Widget build(BuildContext context) {
    final Widget? badge = open == null
        ? null
        : _Pill(
            height: m.button * 0.78,
            color: _kBadgeBg,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: m.pillText * 0.6,
                  height: m.pillText * 0.6,
                  decoration: BoxDecoration(
                    color: open! ? _kOpenDot : _kClosedDot,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: m.pillText * 0.5),
                Text(
                  open! ? s.openNow : s.closedNow,
                  style: _font(m.pillText * 1.08, FontWeight.w600,
                      open! ? _kBadgeText : _kSubtitle),
                ),
              ],
            ),
          );

    final Widget header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kLogoBorder, width: 1.5),
          ),
          padding: const EdgeInsets.all(2),
          child: CompanyLogo(
            name: company.name,
            brandColor: Color(company.coverColorHex),
            imageUrl: company.logoUrl,
            size: m.logo - 7,
            radius: m.logo,
          ),
        ),
        SizedBox(width: m.gap * 0.7),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: m.logo * 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  company.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _font(m.title, FontWeight.w800, _kTitle,
                      spacing: -m.title * 0.02, height: 1.15),
                ),
                SizedBox(height: m.subtitle * 0.3),
                Text(
                  company.category.labelOf(s),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _font(m.subtitle, FontWeight.w400, _kSubtitle),
                ),
                // Phones: the action row can't fit three pills, so the
                // open/closed badge sits under the subtitle instead.
                if (!wide && badge != null) ...<Widget>[
                  const SizedBox(height: 8),
                  badge,
                ],
              ],
            ),
          ),
        ),
        SizedBox(width: m.gap * 0.4),
        _HeartButton(
          size: m.heart,
          iconSize: m.heartIcon,
          active: favorite,
          label: company.name,
          onTap: onFavorite,
        ),
      ],
    );

    final Widget cta = _CollectButton(
      label: s.collectPoints,
      height: m.button,
      fontSize: m.buttonText,
      onTap: onCollect,
    );
    final Widget? pill = campaigns > 0
        ? _Pill(
            height: m.button * 0.78,
            color: _kPillBg,
            child: Text(
              s.moreCampaigns(campaigns),
              style: _font(m.pillText, FontWeight.w500, _kPillText),
            ),
          )
        : null;
    final Widget actions = wide
        ? Row(
            children: <Widget>[
              cta,
              if (pill != null) ...<Widget>[SizedBox(width: m.gap * 0.5), pill],
              const Spacer(),
              if (badge != null) badge,
            ],
          )
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[cta, if (pill != null) pill],
          );

    final Widget footer = Row(
      children: <Widget>[
        Icon(Icons.location_on_outlined,
            size: m.footerIcon, color: _kFooterText),
        SizedBox(width: m.footerText * 0.4),
        Expanded(
          child: Text(
            company.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _font(m.footerText, FontWeight.w400, _kFooterText),
          ),
        ),
        if (distanceKm != null) ...<Widget>[
          SizedBox(width: m.gap * 0.4),
          Icon(Icons.near_me_outlined,
              size: m.footerIcon * 0.9, color: _kFooterText),
          SizedBox(width: m.footerText * 0.4),
          Text(
            _fmtDistance(distanceKm!),
            style: _font(m.footerText, FontWeight.w500, _kFooterText),
          ),
        ],
      ],
    );

    final bool hasFooter = company.address.isNotEmpty || distanceKm != null;

    final List<Widget> children = <Widget>[
      header,
      SizedBox(height: m.rowGap),
      actions,
      if (features.isNotEmpty) ...<Widget>[
        SizedBox(height: m.rowGap),
        _FeatureRow(
            features: features, m: m, wide: wide, s: s, innerWidth: innerWidth),
      ],
      if (hasFooter) ...<Widget>[
        if (wide) const Spacer() else SizedBox(height: m.rowGap),
        const Divider(height: 1, thickness: 1, color: _kDivider),
        SizedBox(height: m.rowGap * 0.8),
        footer,
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
      children: children,
    );
  }
}

// ───────────────────── Compact content (phones) ─────────────────────

/// Right column of the phone card — the reference layout squeezed to
/// ~150 dp: open status joins the category line, amenities become
/// icon-only cells with hairline dividers.
class _CompactContent extends StatelessWidget {
  const _CompactContent({
    required this.company,
    required this.s,
    required this.favorite,
    required this.onFavorite,
    required this.onCollect,
    required this.open,
    required this.campaigns,
    required this.features,
    required this.distanceKm,
  });

  final Company company;
  final S s;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onCollect;
  final bool? open;
  final int campaigns;
  final List<_Feature> features;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final List<_Feature> icons = features.take(5).toList(growable: false);
    final bool hasFooter = company.address.isNotEmpty || distanceKm != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // ── Logo · name/category · heart ──
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kLogoBorder),
              ),
              child: CompanyLogo(
                name: company.name,
                brandColor: Color(company.coverColorHex),
                imageUrl: company.logoUrl,
                size: 32,
                radius: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    company.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _font(14.5, FontWeight.w800, _kTitle,
                        spacing: -0.2, height: 1.2),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          company.category.labelOf(s),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _font(11, FontWeight.w400, _kSubtitle),
                        ),
                      ),
                      if (open != null) ...<Widget>[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: open! ? _kOpenDot : _kClosedDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          open! ? s.openNow : s.closedNow,
                          style: _font(
                            11,
                            FontWeight.w600,
                            open! ? _kBadgeText : _kSubtitle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            _HeartButton(
              size: 30,
              iconSize: 16,
              active: favorite,
              label: company.name,
              onTap: onFavorite,
            ),
          ],
        ),

        // ── CTA + campaigns ──
        const SizedBox(height: 9),
        Row(
          children: <Widget>[
            _CollectButton(
              label: s.collectPoints,
              height: 28,
              fontSize: 11.5,
              hPad: 11,
              onTap: onCollect,
            ),
            if (campaigns > 0) ...<Widget>[
              const SizedBox(width: 6),
              Flexible(
                child: _Pill(
                  height: 24,
                  color: _kPillBg,
                  child: Flexible(
                    child: Text(
                      s.moreCampaignsShort(campaigns),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _font(11, FontWeight.w500, _kPillText),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        // ── Amenity icons ──
        if (icons.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              for (int i = 0; i < icons.length; i++) ...<Widget>[
                if (i > 0) Container(width: 1, height: 12, color: _kDivider),
                Expanded(
                  child: Tooltip(
                    message: icons[i].label(s),
                    child: Icon(
                      icons[i].icon,
                      size: 17,
                      color: _kFeatureIcon,
                      semanticLabel: icons[i].label(s),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],

        // ── Location ──
        if (hasFooter) ...<Widget>[
          const SizedBox(height: 9),
          const Divider(height: 1, thickness: 1, color: _kDivider),
          const SizedBox(height: 7),
          Row(
            children: <Widget>[
              const Icon(Icons.location_on_outlined,
                  size: 13, color: _kFooterText),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  company.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _font(11, FontWeight.w400, _kFooterText),
                ),
              ),
              if (distanceKm != null) ...<Widget>[
                const SizedBox(width: 6),
                const Icon(Icons.near_me_outlined,
                    size: 12, color: _kFooterText),
                const SizedBox(width: 3),
                Text(
                  _fmtDistance(distanceKm!),
                  style: _font(11, FontWeight.w500, _kFooterText),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _HeartButton extends ConsumerWidget {
  const _HeartButton({
    required this.size,
    required this.iconSize,
    required this.active,
    required this.label,
    required this.onTap,
  });

  final double size;
  final double iconSize;
  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      toggled: active,
      label: '${ref.watch(sProvider).favoriteSemantic}: $label',
      child: Material(
        color: _kHeartBg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (Widget w, Animation<double> a) =>
                  ScaleTransition(scale: a, child: w),
              child: Icon(
                active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey<bool>(active),
                size: iconSize,
                color: _kHeart,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectButton extends StatelessWidget {
  const _CollectButton({
    required this.label,
    required this.height,
    required this.fontSize,
    required this.onTap,
    this.hPad,
  });

  final String label;
  final double height;
  final double fontSize;
  final VoidCallback onTap;

  /// Horizontal padding; defaults to the spec's generous pill padding.
  final double? hPad;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _kCta,
        borderRadius: BorderRadius.circular(height),
        boxShadow: AppShadows.brand(_kCta),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(height),
          hoverColor: AppColors.actionPressed.withValues(alpha: 0.4),
          highlightColor: AppColors.actionPressed.withValues(alpha: 0.5),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad ?? height * 0.62),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(label,
                      style:
                          _font(fontSize, FontWeight.w600, AppColors.onDark)),
                  SizedBox(width: fontSize * 0.2),
                  Icon(Icons.chevron_right_rounded,
                      size: fontSize * 1.35, color: AppColors.onDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.height, required this.color, required this.child});

  final double height;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // No `alignment` here: that would make the pill stretch to the full
    // row width inside a Wrap. The min-size Row centres it vertically.
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[child]),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.features,
    required this.m,
    required this.wide,
    required this.s,
    required this.innerWidth,
  });

  final List<_Feature> features;
  final _M m;
  final bool wide;
  final S s;
  final double innerWidth;

  Widget _item(_Feature f) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(f.icon, size: m.featureIcon, color: _kFeatureIcon),
          SizedBox(height: m.featureText * 0.45),
          Text(
            f.label(s),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: _font(m.featureText, FontWeight.w400, _kFeatureText,
                height: 1.2),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      // 3×2 grid, no dividers.
      final double cell = innerWidth / 3;
      return Wrap(
        runSpacing: m.rowGap * 0.8,
        children: <Widget>[
          for (final _Feature f in features)
            SizedBox(width: cell, child: _item(f)),
        ],
      );
    }
    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < features.length; i++) {
      if (i > 0) {
        cells.add(Container(
          width: 1,
          height: (m.featureIcon + m.featureText * 2.9) * 0.6,
          color: _kDivider,
        ));
      }
      cells.add(Expanded(child: _item(features[i])));
    }
    return Row(children: cells);
  }
}

class _Feature {
  const _Feature(this.code, this.icon);

  final String code;
  final IconData icon;

  static const List<_Feature> all = <_Feature>[
    _Feature('WIFI', Icons.wifi_rounded),
    _Feature('WORKSPACE', Icons.laptop_outlined),
    _Feature('MEETING', Icons.groups_outlined),
    _Feature('PARKING', Icons.directions_car_outlined),
    _Feature('GARDEN', Icons.deck_outlined),
    _Feature('VEGAN', Icons.eco_outlined),
    _Feature('PET', Icons.pets_outlined),
  ];

  String label(S s) {
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
}

/// "800 m" under 1 km, otherwise "1.2 km".
String _fmtDistance(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  if (km >= 100) return '${km.round()} km';
  return '${km.toStringAsFixed(1)} km';
}

/// Parses free-text hours like "09:00 – 23:00" (also overnight ranges such
/// as "18:00-02:00"). Returns null when the text isn't a single
/// recognisable range, so no badge is shown rather than a wrong one.
bool? _isOpenNow(String? hours, DateTime now) {
  if (hours == null) return null;
  final RegExpMatch? m =
      RegExp(r'(\d{1,2})[:.](\d{2})\s*[-–—]\s*(\d{1,2})[:.](\d{2})')
          .firstMatch(hours);
  if (m == null) return null;
  final int start = int.parse(m[1]!) * 60 + int.parse(m[2]!);
  int end = int.parse(m[3]!) * 60 + int.parse(m[4]!);
  if (end == 0) end = 24 * 60; // "…– 00:00" means until midnight
  final int t = now.hour * 60 + now.minute;
  if (start == end) return true; // 00:00 – 24:00 style → always open
  return start < end ? (t >= start && t < end) : (t >= start || t < end);
}
