import 'dart:io' show File;
import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/location/device_location.dart';
import '../../menu/data/menu_repository.dart';
import '../../menu/presentation/menu_preview.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/company_logo.dart';
import '../../../core/widgets/empty_state.dart';
import '../../favorites/application/favorites_providers.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../reviews/application/reviews_providers.dart';
import '../../reviews/presentation/reviews_section.dart';
import 'widgets/location_map.dart';
import '../../loyalty/domain/loyalty_card.dart';
import '../../loyalty/domain/loyalty_program.dart';
import '../../rewards/application/rewards_providers.dart';
import '../../rewards/data/rewards_repository.dart';
import '../../wallet/application/wallet_providers.dart';
import '../../wallet/domain/coin_reward.dart';
import '../../wallet/domain/coin_summary.dart';
import '../application/companies_providers.dart';
import '../domain/company.dart';
import '../../../core/utils/maps_launcher.dart';
import '../../../core/utils/money.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CompanyDetailScreen extends ConsumerWidget {
  const CompanyDetailScreen({super.key, required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<Company?> companyAsync =
        ref.watch(companyByIdProvider(companyId));
    final AsyncValue<List<LoyaltyProgram>> programsAsync =
        ref.watch(programsForCompanyProvider(companyId));
    final AsyncValue<List<LoyaltyCard>> cardsAsync = ref.watch(myCardsProvider);

    // Every non-content state keeps a way back and a way to try again.
    Widget bare(Widget body) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/home'),
            ),
          ),
          body: body,
        );
    void retry() => ref.invalidate(companyByIdProvider(companyId));

    return companyAsync.when(
      // A failed pull-to-refresh keeps the page that is already shown.
      skipError: true,
      loading: () => bare(const Center(child: CircularProgressIndicator())),
      error: (Object e, _) => bare(EmptyState(
        title: s.error,
        subtitle: e is ApiException ? e.message : s.errorTryAgain,
        icon: AppIcons.error,
        action: TextButton(onPressed: retry, child: Text(s.retry)),
      )),
      data: (Company? company) {
        if (company == null) {
          return bare(EmptyState(
            title: s.notFound,
            icon: AppIcons.searchOff,
            action: TextButton(onPressed: retry, child: Text(s.retry)),
          ));
        }
        return Scaffold(
          body: _Body(
            company: company,
            programsAsync: programsAsync,
            cardsAsync: cardsAsync,
          ),
        );
      },
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({
    required this.company,
    required this.programsAsync,
    required this.cardsAsync,
  });

  final Company company;
  final AsyncValue<List<LoyaltyProgram>> programsAsync;
  final AsyncValue<List<LoyaltyCard>> cardsAsync;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  // Anchors for the Campaigns / Menu / About tabs.
  final GlobalKey _campaignsKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();

  Company get company => widget.company;
  AsyncValue<List<LoyaltyProgram>> get programsAsync => widget.programsAsync;

  LoyaltyCard? _cardFor(String programId) => widget.cardsAsync.maybeWhen(
        data: (List<LoyaltyCard> cards) {
          for (final LoyaltyCard c in cards) {
            if (c.programId == programId) return c;
          }
          return null;
        },
        orElse: () => null,
      );

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final Color brand = Color(company.coverColorHex);
    final double topInset = MediaQuery.paddingOf(context).top;
    final bool hasCoinRewards =
        ref.watch(coinRewardsProvider(company.id)).maybeWhen(
              data: (List<CoinReward> r) => r.any((CoinReward x) => x.active),
              orElse: () => false,
            );
    // The "Menu" tab scrolls to the inline menu, which renders nothing
    // without structured items — so the tab only appears when it has
    // something to show. A link-only menu still opens from the Menu button.
    final bool hasMenuItems =
        ref.watch(companyMenuProvider(company.id)).valueOrNull?.isNotEmpty ??
            false;

    return Stack(
      children: <Widget>[
        RefreshIndicator(
          // Programs, gifts and the customer's own progress can change
          // while the page is open (owner edits, a tap at the till).
          onRefresh: () async {
            ref
              ..invalidate(programsForCompanyProvider(company.id))
              ..invalidate(coinRewardsProvider(company.id))
              ..invalidate(companyByIdProvider(company.id))
              ..invalidate(companyReviewsProvider(company.id))
              ..invalidate(companyMenuProvider(company.id))
              ..invalidate(myCardsProvider)
              ..invalidate(coinSummaryProvider);
          },
          child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            _PhotoHeader(company: company, brand: brand),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: <Widget>[
                    _InfoCard(
                      company: company,
                      actions: _ActionButtons(
                        company: company,
                        onShowQr: () => context.go('/nfc'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SectionTabs(
                      labels: <String>[
                        s.campaigns,
                        if (hasMenuItems) s.menuWord,
                        s.aboutTab,
                      ],
                      anchors: <GlobalKey>[
                        _campaignsKey,
                        if (hasMenuItems) _menuKey,
                        _aboutKey,
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _OffersCard(
                      key: _campaignsKey,
                      company: company,
                      programsAsync: programsAsync,
                      hasCoinRewards: hasCoinRewards,
                      cardFor: _cardFor,
                      onJoin: (LoyaltyProgram p) async {
                        try {
                          await ref
                              .read(loyaltyActionsProvider)
                              .joinProgram(p.id);
                        } on ApiException catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message)));
                          }
                          return;
                        }
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${company.name} ${s.cardAddedSuffix}'),
                          ),
                        );
                      },
                      onShowQr: () => context.go('/nfc'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    MenuPreview(
                      key: _menuKey,
                      companyId: company.id,
                      currency: company.currency,
                      onOpenFull: (List<MenuItem> items) =>
                          showModalBottomSheet<void>(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        showDragHandle: false,
                        builder: (BuildContext _) =>
                            _MenuSheet(items: items, currency: company.currency),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _CoinRewardsSection(company: company),
                    SizedBox(key: _aboutKey, height: 0),
                    if (company.latitude != null &&
                        company.longitude != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      LocationMap(
                        latitude: company.latitude!,
                        longitude: company.longitude!,
                        companyName: company.name,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    ReviewsSection(
                      companyId: company.id,
                      companyName: company.name,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
        // Floating back / actions over the photo.
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            topInset + AppSpacing.sm,
            AppSpacing.lg,
            0,
          ),
          child: Row(
            children: <Widget>[
              _GlassCircle(
                icon: AppIcons.back,
                onTap: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
              ),
              const Spacer(),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, _) {
                  final bool fav =
                      ref.watch(favoritesProvider).contains(company.id);
                  return _GlassCircle(
                    icon: fav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: fav ? AppColors.danger : null,
                    onTap: () =>
                        ref.read(favoritesProvider.notifier).toggle(company.id),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              _GlassCircle(
                icon: AppIcons.share,
                onTap: () => _shareCompany(company, s),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Branded "photo" carousel. The model has no images yet, so each slide
/// is a tasteful brand-tinted panel with the monogram; it swaps to real
/// photos the moment the backend exposes them.
class _PhotoHeader extends StatefulWidget {
  const _PhotoHeader({required this.company, required this.brand});

  final Company company;
  final Color brand;

  @override
  State<_PhotoHeader> createState() => _PhotoHeaderState();
}

/// Shares the venue the way a place should be shared: the cover photo as
/// an image plus a caption with name, category · rating, tagline, address,
/// hours, a Google Maps link and an invite line.
///
/// No `subject` — several targets (Telegram, some messengers, mail) used
/// only the subject, which is why the old share showed just the name.
Future<void> _shareCompany(Company company, S s) async {
  final StringBuffer msg = StringBuffer();
  msg.writeln(company.name);
  final List<String> meta = <String>[
    company.category.labelOf(s),
    if (company.rating > 0) '⭐ ${company.rating.toStringAsFixed(1)}',
  ];
  msg.writeln(meta.join(' · '));
  if (company.tagline.trim().isNotEmpty) {
    msg.writeln(company.tagline.trim());
  }
  msg.writeln();
  if (company.address.trim().isNotEmpty) {
    msg.writeln('📍 ${company.address.trim()}');
  }
  if ((company.workingHours ?? '').trim().isNotEmpty) {
    msg.writeln('🕒 ${company.workingHours!.trim()}');
  }
  if ((company.phone ?? '').trim().isNotEmpty) {
    msg.writeln('📞 ${company.phone!.trim()}');
  }
  if (company.latitude != null && company.longitude != null) {
    msg.writeln(
        '🗺 ${s.shareOnMap}: ${googleMapsLink(company.latitude!, company.longitude!)}');
  }
  msg.writeln();
  msg.write('🎁 ${s.shareDiscover}');
  final String text = msg.toString();

  // Attach the cover photo when we can get it (usually already cached
  // from the header); otherwise share the text alone.
  if (company.photoUrls.isNotEmpty) {
    try {
      final File file = await DefaultCacheManager()
          .getSingleFile(company.photoUrls.first)
          .timeout(const Duration(seconds: 6));
      await Share.shareXFiles(
        <XFile>[XFile(file.path, mimeType: 'image/jpeg')],
        text: text,
      );
      return;
    } catch (_) {
      // fall through to text-only
    }
  }
  await Share.share(text);
}

class _PhotoHeaderState extends State<_PhotoHeader> {
  final PageController _pc = PageController();
  int _i = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color b = widget.brand;
    final List<String> photos = widget.company.photoUrls;
    final bool hasPhotos = photos.isNotEmpty;
    final List<List<Color>> palettes = <List<Color>>[
      <Color>[b, _shift(b, -0.16)],
      <Color>[_shift(b, 0.08), _shift(b, -0.22)],
      AppColors.heroGradient,
      <Color>[_shift(b, -0.05), _shift(b, -0.30)],
    ];
    final int count = hasPhotos ? photos.length : 4;

    Widget brandPanel(int idx) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palettes[idx % palettes.length],
            ),
          ),
          child: Center(
            child: CompanyLogo(
              name: widget.company.name,
              brandColor: AppColors.onDark,
              imageUrl: widget.company.logoUrl,
              size: 96,
              radius: 28,
            ),
          ),
        );

    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PageView.builder(
            controller: _pc,
            onPageChanged: (int v) => setState(() => _i = v),
            itemCount: count,
            itemBuilder: (BuildContext _, int idx) {
              if (!hasPhotos) return brandPanel(idx);
              return CachedNetworkImage(
                imageUrl: photos[idx],
                fit: BoxFit.cover,
                placeholder: (_, __) => brandPanel(idx),
                errorWidget: (_, __, ___) => brandPanel(idx),
              );
            },
          ),
          Positioned(
            right: AppSpacing.lg,
            bottom: 44,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.media.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.photo_library_outlined,
                      size: 13, color: AppColors.onDark),
                  const SizedBox(width: 4),
                  Text('${_i + 1} / $count',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.onDark,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _shift(Color c, double amount) {
    final HSLColor h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}

/// Round button floating on the venue photo. Frosted dark glass with a
/// white icon, so it reads on any photo in light and dark mode alike.
class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.icon, this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: AppColors.media.withValues(alpha: 0.32),
          shape: CircleBorder(
            side: BorderSide(
              color: AppColors.onDark.withValues(alpha: 0.28),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            splashColor: AppColors.onDark.withValues(alpha: 0.18),
            highlightColor: AppColors.onDark.withValues(alpha: 0.10),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(icon, size: 19, color: iconColor ?? AppColors.onDark),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends ConsumerWidget {
  const _InfoCard({required this.company, required this.actions});

  final Company company;

  /// Menu / Kartı okut buttons, shown at the bottom of the card.
  final Widget actions;

  static const List<_Amenity> _amenities = <_Amenity>[
    _Amenity('WIFI', Icons.wifi_rounded),
    _Amenity('WORKSPACE', Icons.laptop_mac_rounded),
    _Amenity('MEETING', Icons.groups_rounded),
    _Amenity('GARDEN', Icons.park_rounded),
    _Amenity('PARKING', Icons.local_parking_rounded),
    _Amenity('VEGAN', Icons.eco_rounded),
    _Amenity('PET', Icons.pets_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    final ({double lat, double lng})? device =
        ref.watch(deviceLocationProvider).value;
    final double? distanceKm = distanceKmBetween(
          device: device,
          targetLat: company.latitude,
          targetLng: company.longitude,
        ) ??
        company.distanceKm;
    final bool hasMap = company.latitude != null && company.longitude != null;
    final String hours = (company.workingHours ?? '').trim();
    final String phone = (company.phone ?? '').trim();
    final String subtitle = <String>[
      company.category.labelOf(s),
      if (distanceKm != null)
        distanceKm < 1
            ? '${(distanceKm * 1000).round()} m'
            : '${distanceKm.toStringAsFixed(1)} km',
    ].join(' · ');

    Widget hairline() => Divider(height: AppSpacing.xl, color: p.divider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CompanyLogo(
                name: company.name,
                brandColor: Color(company.coverColorHex),
                imageUrl: company.logoUrl,
                size: 58,
                radius: 16,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            company.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h2.copyWith(
                              color: context.palette.ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (company.isApproved) ...<Widget>[
                          const SizedBox(width: 6),
                          Icon(Icons.verified_rounded,
                              size: 19, color: p.caramel),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.bodySm
                            .copyWith(color: p.textSecondary)),
                  ],
                ),
              ),
              if (company.rating > 0) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: p.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.star_rounded,
                              size: 17, color: AppColors.reward),
                          const SizedBox(width: 3),
                          Text(company.rating.toStringAsFixed(1),
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: p.textPrimary)),
                        ],
                      ),
                      if (company.reviewCount > 0)
                        Text('(${company.reviewCount})',
                            style: AppTextStyles.caption
                                .copyWith(color: p.textSecondary)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (company.address.trim().isNotEmpty) ...<Widget>[
            hairline(),
            InkWell(
              onTap: !hasMap
                  ? null
                  : () => openDirections(
                        latitude: company.latitude!,
                        longitude: company.longitude!,
                        label: company.name,
                      ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.place_outlined, size: 19, color: p.caramel),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(company.address.trim(),
                        style: AppTextStyles.bodySm.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: p.textPrimary)),
                  ),
                  if (hasMap)
                    Icon(Icons.chevron_right_rounded,
                        size: 20, color: p.textSecondary),
                ],
              ),
            ),
          ],
          if (hours.isNotEmpty || phone.isNotEmpty) ...<Widget>[
            hairline(),
            Row(
              children: <Widget>[
                if (hours.isNotEmpty) ...<Widget>[
                  Icon(Icons.schedule_rounded, size: 18, color: p.caramel),
                  const SizedBox(width: 6),
                  Text(hours,
                      style: AppTextStyles.bodySm.copyWith(
                          fontSize: 14,
                          color: p.caramelText,
                          fontWeight: FontWeight.w700)),
                ],
                if (hours.isNotEmpty && phone.isNotEmpty)
                  Container(
                    width: 1,
                    height: 18,
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    color: p.divider,
                  ),
                if (phone.isNotEmpty)
                  Flexible(
                    child: InkWell(
                      onTap: () => launchUrl(Uri(scheme: 'tel', path: phone)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.call_outlined,
                              size: 17, color: p.caramel),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(phone,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySm.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: p.textPrimary)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
          // Amenities only render if the owner enabled at least one.
          if (_activeAmenities.isNotEmpty) ...<Widget>[
            hairline(),
            // Up to five fit evenly across the card; more scroll sideways.
            if (_activeAmenities.length <= 5)
              Row(
                children: <Widget>[
                  for (final _Amenity a in _activeAmenities)
                    Expanded(child: _AmenityChip(amenity: a, active: true)),
                  for (int i = _activeAmenities.length; i < 5; i++)
                    const Spacer(),
                ],
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    for (final _Amenity a in _activeAmenities) ...<Widget>[
                      SizedBox(
                          width: 64,
                          child: _AmenityChip(amenity: a, active: true)),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          actions,
        ],
      ),
    );
  }

  List<_Amenity> get _activeAmenities => _amenities
      .where((_Amenity a) => company.amenities.contains(a.code))
      .toList(growable: false);
}

/// Segmented tabs that scroll the page to Campaigns / Menu / About.
class _SectionTabs extends StatefulWidget {
  const _SectionTabs({required this.labels, required this.anchors});

  final List<String> labels;
  final List<GlobalKey> anchors;

  @override
  State<_SectionTabs> createState() => _SectionTabsState();
}

class _SectionTabsState extends State<_SectionTabs> {
  int _i = 0;

  void _go(int i) {
    setState(() => _i = i);
    final BuildContext? target = widget.anchors[i].currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < widget.labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _go(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    gradient: i == _i
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.actionGradient,
                          )
                        : null,
                  ),
                  child: Text(
                    widget.labels[i],
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 14,
                      fontWeight: i == _i ? FontWeight.w700 : FontWeight.w500,
                      color: i == _i ? AppColors.onDark : p.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Amenity {
  const _Amenity(this.code, this.icon);
  final String code;
  final IconData icon;

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

class _AmenityChip extends ConsumerWidget {
  const _AmenityChip({required this.amenity, required this.active});

  final _Amenity amenity;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    return SizedBox(
      child: Column(
        children: <Widget>[
          Container(
            width: 48,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? p.surfaceAccent : p.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              amenity.icon,
              size: 22,
              color: active ? p.caramelText : p.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amenity.label(s),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: p.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Menu + "Kartı okut" — the two main actions at the foot of the info card.
class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.company, required this.onShowQr});

  final Company company;
  final VoidCallback onShowQr;

  Future<void> _openMenu(BuildContext context, List<MenuItem> items) async {
    if (items.isNotEmpty) {
      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        // _MenuSheet draws its own handle.
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        builder: (BuildContext _) =>
            _MenuSheet(items: items, currency: company.currency),
      );
      return;
    }
    final String raw = (company.menuUrl ?? '').trim();
    if (raw.isEmpty) return;
    final String normalized =
        raw.startsWith('http://') || raw.startsWith('https://')
            ? raw
            : 'https://$raw';
    final Uri? uri = Uri.tryParse(normalized);
    if (uri == null) return;
    final bool ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (!ok && context.mounted) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final List<MenuItem> menuItems =
        ref.watch(companyMenuProvider(company.id)).value ?? const <MenuItem>[];
    final bool showMenuButton = company.hasMenu || menuItems.isNotEmpty;
    return Row(
      children: <Widget>[
        if (showMenuButton) ...<Widget>[
          Expanded(
            flex: 10,
            child: _BigButton(
              label: s.menuWord,
              icon: Icons.restaurant_menu_rounded,
              filled: false,
              onTap: () => _openMenu(context, menuItems),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          flex: showMenuButton ? 13 : 1,
          child: _BigButton(
            label: s.nfcTapShort,
            icon: AppIcons.nfc,
            filled: true,
            onTap: onShowQr,
          ),
        ),
      ],
    );
  }
}

class _OffersCard extends ConsumerWidget {
  const _OffersCard({
    super.key,
    required this.company,
    required this.programsAsync,
    required this.hasCoinRewards,
    required this.cardFor,
    required this.onJoin,
    required this.onShowQr,
  });

  final Company company;
  final AsyncValue<List<LoyaltyProgram>> programsAsync;

  /// True when this business runs the coin/gift system. When it does and
  /// there are no stamp campaigns, the campaign block is hidden entirely
  /// (no "no campaigns yet" text) — the two systems are mutually exclusive.
  final bool hasCoinRewards;

  final LoyaltyCard? Function(String programId) cardFor;
  final Future<void> Function(LoyaltyProgram program) onJoin;
  final VoidCallback onShowQr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return programsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object e, _) => Text(e.toString()),
      data: (List<LoyaltyProgram> all) {
        // A paused or expired campaign is not on offer to customers.
        final DateTime now = DateTime.now();
        final List<LoyaltyProgram> programs = all
            .where((LoyaltyProgram p) =>
                p.isActive &&
                (p.expiresAt == null || p.expiresAt!.isAfter(now)))
            .toList(growable: false);
        if (programs.isEmpty && hasCoinRewards) return const SizedBox.shrink();
        if (programs.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: context.palette.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.sm,
            ),
            child: EmptyState(
              title: s.noCampaignYet,
              subtitle: s.campaignComingSoon,
              icon: AppIcons.gift,
            ),
          );
        }
        return Column(
          children: <Widget>[
            for (int i = 0; i < programs.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              _CampaignRow(
                program: programs[i],
                card: cardFor(programs[i].id),
                onJoin: () => onJoin(programs[i]),
                currency: company.currency,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Color fg = filled ? AppColors.onDark : p.caramelText;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        color: filled ? null : p.caramelSoft,
        gradient: filled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.actionGradient,
              )
            : null,
        boxShadow: filled ? AppShadows.brand(AppColors.action) : null,
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon == AppIcons.nfc)
                  NfcWavesIcon(size: 20, color: fg)
                else
                  Icon(icon, size: 19, color: fg),
                const SizedBox(width: AppSpacing.sm),
                Text(label,
                    style: AppTextStyles.button.copyWith(
                        color: fg, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampaignRow extends ConsumerWidget {
  const _CampaignRow({
    required this.program,
    required this.card,
    required this.onJoin,
    required this.currency,
  });

  final LoyaltyProgram program;
  final LoyaltyCard? card;
  final VoidCallback onJoin;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    final int total = program.stampsToFill(card);
    final int done = card?.stamps ?? 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset('assets/illustrations/campaign_gift.png',
              width: 58, filterQuality: FilterQuality.medium),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(program.title,
                              style: AppTextStyles.h3.copyWith(
                                  color: context.palette.ink,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(program.rewardLabelOf(s, currency: currency),
                              style: AppTextStyles.bodySm
                                  .copyWith(color: p.textSecondary)),
                        ],
                      ),
                    ),
                    Text('$done / $total',
                        style: AppTextStyles.h3.copyWith(
                          color: p.caramelText,
                          fontWeight: FontWeight.w800,
                        )),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) {
                    const double gap = 6;
                    final double d =
                        ((c.maxWidth - gap * total) / (total + 1))
                            .clamp(18.0, 30.0)
                            .toDouble();
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: <Widget>[
                        for (int i = 0; i < total; i++)
                          _Dot(size: d, done: i < done, icon: program.rewardType.icon),
                        _Dot(size: d, done: false, reward: true),
                      ],
                    );
                  },
                ),
                if (card == null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: onJoin,
                      child: Text(s.joinCampaign),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One stamp on a campaign card: white with a faint green outline, filled
/// green with a tick once earned, and a mint ring with a gift for the
/// reward slot.
class _Dot extends StatelessWidget {
  const _Dot({
    required this.size,
    required this.done,
    this.icon = AppIcons.gift,
    this.reward = false,
  });

  final double size;
  final bool done;
  final IconData icon;
  final bool reward;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: done
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.actionGradient,
              )
            : null,
        color: done ? null : (reward ? p.surfaceAccent : p.surface),
        border: done
            ? null
            : Border.all(
                color: reward
                    ? p.caramel
                    : p.caramel.withValues(alpha: 0.25),
                width: reward ? 1.6 : 1,
              ),
      ),
      child: Icon(
        done ? AppIcons.check : (reward ? AppIcons.gift : icon),
        size: size * 0.5,
        color: done ? AppColors.onDark : p.caramelText,
      ),
    );
  }
}

/// Customer-facing "Coinlə al" — the company's reward catalog plus the
/// customer's coin balance at this business. Tapping "Al" buys the
/// voucher (coins deduct, ACTIVE claim created); the cashier later
/// marks it used at the counter.
class _CoinRewardsSection extends ConsumerWidget {
  const _CoinRewardsSection({required this.company});

  final Company company;

  Future<void> _buy(
      BuildContext context, WidgetRef ref, CoinReward r, int balance) async {
    final S s = ref.read(sProvider);
    // Coins leave at once, so the customer confirms what they buy here.
    final bool ok = await showConfirmSheet(
      context,
      title: s.buyConfirmTitle,
      body: s.buyConfirmBody(r.title, r.coinCost, balance - r.coinCost),
      confirmLabel: s.buyAction,
      cancelLabel: s.cancel,
      icon: Icons.card_giftcard_rounded,
      danger: AppColors.action,
    );
    if (!ok || !context.mounted) return;
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final GoRouter router = GoRouter.of(context);
    try {
      await container.read(rewardsRepositoryProvider).purchase(r.id);
      // Refresh affected state.
      container
        ..invalidate(coinSummaryProvider)
        ..invalidate(myActiveRewardsProvider)
        ..invalidate(myUsedRewardsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${r.title} ${s.purchasedSeeGifts}'),
          action: SnackBarAction(
            label: s.viewMyRewards,
            onPressed: () => router.push('/rewards'),
          ),
        ),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<CoinReward>> rewardsAsync =
        ref.watch(coinRewardsProvider(company.id));
    final AsyncValue<CoinSummary> summaryAsync = ref.watch(coinSummaryProvider);

    // Unknown until the summary loads: never treat that as a zero balance.
    final int? known = summaryAsync.valueOrNull?.companies
        .where((CompanyBalance b) => b.companyId == company.id)
        .fold<int>(0, (int acc, CompanyBalance b) => acc + b.balance);
    final bool balanceFailed = known == null && summaryAsync.hasError;
    final int balance = known ?? 0;

    return rewardsAsync.maybeWhen(
      data: (List<CoinReward> all) {
        // Owners also get their off-sale items; customers only see on-sale.
        final List<CoinReward> rewards =
            all.where((CoinReward r) => r.active).toList(growable: false);
        if (rewards.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Image.asset('assets/illustrations/coins.png',
                      width: 44, filterQuality: FilterQuality.medium),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                      child: Text(s.buyWithCoin,
                          style: AppTextStyles.h3.copyWith(
                              color: context.palette.ink,
                              fontWeight: FontWeight.w700))),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.caramelSoft,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(AppIcons.token,
                            size: 16, color: AppColors.action),
                        const SizedBox(width: 4),
                        if (known != null)
                          Text('$balance',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.action,
                                fontWeight: FontWeight.w800,
                              ))
                        else if (balanceFailed)
                          InkWell(
                            onTap: () => ref.invalidate(coinSummaryProvider),
                            child: Tooltip(
                              message: s.retry,
                              child: Icon(Icons.refresh_rounded,
                                  size: 18, color: AppColors.action),
                            ),
                          )
                        else
                          SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.action,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                s.buyWithCoinHint,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final CoinReward r in rewards) ...<Widget>[
                _RewardTile(
                  reward: r,
                  affordable: known == null || balance >= r.coinCost,
                  onBuy: known != null && balance >= r.coinCost
                      ? () => _buy(context, ref, r, balance)
                      : null,
                ),
                if (r != rewards.last) const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _RewardTile extends ConsumerWidget {
  const _RewardTile({
    required this.reward,
    required this.affordable,
    required this.onBuy,
  });

  final CoinReward reward;
  final bool affordable;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final Color bgColor =
        affordable ? AppColors.action : AppColors.borderStrong;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: affordable ? AppColors.caramelSoft : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: kHeroGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.gift, color: AppColors.onDark, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  reward.title,
                  style: AppTextStyles.bodyLg
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                if ((reward.description ?? '').isNotEmpty)
                  Text(
                    reward.description!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(AppIcons.token,
                        size: 14,
                        color: affordable
                            ? AppColors.action
                            : AppColors.textTertiary),
                    const SizedBox(width: 2),
                    Text('${reward.coinCost}',
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w800,
                          color: affordable
                              ? AppColors.action
                              : AppColors.textTertiary,
                        )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: InkWell(
              onTap: onBuy,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: 10),
                child: Text(
                  affordable ? s.buyAction : s.insufficientWord,
                  style: const TextStyle(
                    color: AppColors.onDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only structured menu shown to customers, grouped by category.
class _MenuSheet extends StatelessWidget {
  const _MenuSheet({required this.items, this.currency = 'AZN'});

  final List<MenuItem> items;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<MenuItem>> byCat = <String, List<MenuItem>>{};
    for (final MenuItem m in items) {
      byCat.putIfAbsent(m.category, () => <MenuItem>[]).add(m);
    }
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (BuildContext context, ScrollController controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
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
            Consumer(
              builder: (BuildContext _, WidgetRef ref, Widget? __) => Text(
                  ref.watch(sProvider).menuWord,
                  style: AppTextStyles.h2),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final MapEntry<String, List<MenuItem>> e
                in byCat.entries) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: AppSpacing.lg, bottom: AppSpacing.sm),
                child: Text(e.key,
                    style: AppTextStyles.overline
                        .copyWith(color: AppColors.action)),
              ),
              for (final MenuItem m in e.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(m.name,
                                style: AppTextStyles.bodyLg
                                    .copyWith(fontWeight: FontWeight.w600)),
                            if ((m.description ?? '').isNotEmpty)
                              Text(m.description!,
                                  style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (m.price != null) ...<Widget>[
                        const SizedBox(width: AppSpacing.md),
                        Text(Money.format(m.price!, currency),
                            style: AppTextStyles.bodyLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.action,
                            )),
                      ],
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
