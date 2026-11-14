import 'dart:io' show File;

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

    return Scaffold(
      body: companyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: s.error,
          subtitle: e.toString(),
          icon: AppIcons.error,
        ),
        data: (Company? company) {
          if (company == null) {
            return EmptyState(
              title: s.notFound,
              icon: AppIcons.searchOff,
            );
          }
          return _Body(
            company: company,
            programsAsync: programsAsync,
            cardsAsync: cardsAsync,
          );
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.company,
    required this.programsAsync,
    required this.cardsAsync,
  });

  final Company company;
  final AsyncValue<List<LoyaltyProgram>> programsAsync;
  final AsyncValue<List<LoyaltyCard>> cardsAsync;

  LoyaltyCard? _cardFor(String programId) => cardsAsync.maybeWhen(
        data: (List<LoyaltyCard> cards) {
          for (final LoyaltyCard c in cards) {
            if (c.programId == programId) return c;
          }
          return null;
        },
        orElse: () => null,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final Color brand = Color(company.coverColorHex);
    final double topInset = MediaQuery.paddingOf(context).top;
    final bool hasCoinRewards =
        ref.watch(coinRewardsProvider(company.id)).maybeWhen(
              data: (List<CoinReward> r) => r.any((CoinReward x) => x.active),
              orElse: () => false,
            );

    return Stack(
      children: <Widget>[
        RefreshIndicator(
          // Programs, gifts and the customer's own progress can change
          // while the page is open (owner edits, a tap at the till).
          onRefresh: () async {
            ref
              ..invalidate(programsForCompanyProvider(company.id))
              ..invalidate(coinRewardsProvider(company.id))
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
                    _InfoCard(company: company),
                    const SizedBox(height: AppSpacing.lg),
                    _OffersCard(
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
            left: 0,
            right: 0,
            bottom: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(count, (int d) {
                final bool on = d == _i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: on ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.onDark.withValues(alpha: on ? 1 : 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
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

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.icon, this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onDark,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child:
              Icon(icon, size: 19, color: iconColor ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _InfoCard extends ConsumerWidget {
  const _InfoCard({required this.company});

  final Company company;

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
    final ({double lat, double lng})? device =
        ref.watch(deviceLocationProvider).value;
    final double? distanceKm = distanceKmBetween(
          device: device,
          targetLat: company.latitude,
          targetLng: company.longitude,
        ) ??
        company.distanceKm;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.md,
      ),
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
                    Text(company.name, style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text(
                      <String>[
                        if (company.address.isNotEmpty) company.address,
                        company.category.labelOf(s),
                      ].join(' • '),
                      style: AppTextStyles.bodySm,
                    ),
                    if (distanceKm != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          const Icon(AppIcons.location,
                              size: 14, color: AppColors.action),
                          const SizedBox(width: 4),
                          Text(
                            distanceKm < 1
                                ? '${(distanceKm * 1000).round()} m uzaqda'
                                : '${distanceKm.toStringAsFixed(1)} km uzaqda',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.action,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if ((company.workingHours ?? '').isNotEmpty ||
                        (company.phone ?? '').isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          if ((company.workingHours ?? '')
                              .isNotEmpty) ...<Widget>[
                            const Icon(AppIcons.clock,
                                size: 14, color: AppColors.action),
                            const SizedBox(width: 4),
                            Text(company.workingHours!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.action,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                          if ((company.workingHours ?? '').isNotEmpty &&
                              (company.phone ?? '').isNotEmpty)
                            Text('  ·  ', style: AppTextStyles.caption),
                          if ((company.phone ?? '').isNotEmpty)
                            Text(company.phone!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                )),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _RoundAction(icon: AppIcons.clock),
              const SizedBox(width: 6),
              _RoundAction(
                  icon: AppIcons.star,
                  iconColor: AppColors.reward, // star rating = reward colour
                  label: company.rating.toStringAsFixed(1)),
              const SizedBox(width: 6),
              _RoundAction(
                icon: AppIcons.location,
                onTap: company.latitude == null || company.longitude == null
                    ? null
                    : () => openDirections(
                          latitude: company.latitude!,
                          longitude: company.longitude!,
                          label: company.name,
                        ),
              ),
            ],
          ),
          // Amenities only render if the owner enabled at least one.
          if (_activeAmenities.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final _Amenity a in _activeAmenities) ...<Widget>[
                    _AmenityChip(amenity: a, active: true),
                    const SizedBox(width: AppSpacing.lg),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<_Amenity> get _activeAmenities => _amenities
      .where((_Amenity a) => company.amenities.contains(a.code))
      .toList(growable: false);
}

class _RoundAction extends StatelessWidget {
  const _RoundAction(
      {required this.icon, this.label, this.iconColor, this.onTap});

  final IconData icon;
  final String? label;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget pill = Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: label == null ? 0 : 12),
      width: label == null ? 40 : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.caramelSoft,
        shape: label == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            label == null ? null : BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: iconColor ?? AppColors.action),
          if (label != null) ...<Widget>[
            const SizedBox(width: 4),
            Text(label!,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.action,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ],
      ),
    );
    if (onTap == null) return pill;
    return GestureDetector(onTap: onTap, child: pill);
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
    final bool on = active;
    return Column(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.caramelSoft : AppColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(
            amenity.icon,
            size: 22,
            color: on ? AppColors.action : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          amenity.label(s),
          style: AppTextStyles.caption.copyWith(
            color: on ? AppColors.action : AppColors.textTertiary,
            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OffersCard extends ConsumerWidget {
  const _OffersCard({
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

  /// Opens the menu. If the business built a structured menu, shows it
  /// grouped by category in a sheet; otherwise falls back to opening the
  /// menu link in the in-app browser.
  Future<void> _openMenu(BuildContext context, List<MenuItem> items) async {
    if (items.isNotEmpty) {
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
        builder: (BuildContext _) => _MenuSheet(items: items),
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
    // Structured menu items (may be empty — then the link fallback is used).
    final List<MenuItem> menuItems =
        ref.watch(companyMenuProvider(company.id)).value ?? const <MenuItem>[];
    final bool showMenuButton = company.hasMenu || menuItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Menu shows if the owner added a link or built a menu.
              if (showMenuButton) ...<Widget>[
                Expanded(
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
                child: _BigButton(
                  label: s.nfcTapShort,
                  icon: AppIcons.nfc,
                  filled: true,
                  onTap: onShowQr,
                ),
              ),
            ],
          ),
          programsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object e, _) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Text(e.toString()),
            ),
            data: (List<LoyaltyProgram> all) {
              // A paused or expired campaign is not on offer to customers.
              final DateTime now = DateTime.now();
              final List<LoyaltyProgram> programs = all
                  .where((LoyaltyProgram p) =>
                      p.isActive &&
                      (p.expiresAt == null || p.expiresAt!.isAfter(now)))
                  .toList(growable: false);
              final bool hasPrograms = programs.isNotEmpty;
              // Coin-only business: hide the campaign block completely.
              if (!hasPrograms && hasCoinRewards) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.lg),
                  Text(s.campaigns, style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.md),
                  if (!hasPrograms)
                    EmptyState(
                      title: s.noCampaignYet,
                      subtitle: s.campaignComingSoon,
                      icon: AppIcons.gift,
                    )
                  else
                    Column(
                      children: <Widget>[
                        for (int i = 0; i < programs.length; i++) ...<Widget>[
                          _CampaignRow(
                            program: programs[i],
                            card: cardFor(programs[i].id),
                            accent:
                                i.isEven ? AppColors.action : AppColors.caramel,
                            onJoin: () => onJoin(programs[i]),
                            onShowQr: onShowQr,
                            currency: company.currency,
                          ),
                          if (i != programs.length - 1) ...<Widget>[
                            const SizedBox(height: AppSpacing.lg),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ],
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
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
    final Color fg = filled ? AppColors.onDark : AppColors.action;
    return Material(
      color: filled ? AppColors.action : AppColors.caramelSoft,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTextStyles.button.copyWith(color: fg)),
            ],
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
    required this.accent,
    required this.onJoin,
    required this.onShowQr,
    required this.currency,
  });

  final LoyaltyProgram program;
  final LoyaltyCard? card;
  final Color accent;
  final VoidCallback onJoin;
  final VoidCallback onShowQr;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final int total = program.stampsToFill(card);
    final int done = card?.stamps ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(program.rewardType.icon, color: accent, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(program.title, style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text(program.rewardLabelOf(s, currency: currency),
                      style: AppTextStyles.bodySm),
                ],
              ),
            ),
            Text('$done / $total',
                style: AppTextStyles.bodySm.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                )),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            for (int s = 0; s < total; s++) ...<Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: s < done ? accent : accent.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      s < done ? AppIcons.check : program.rewardType.icon,
                      size: 14,
                      color: s < done ? AppColors.onDark : accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            // Reward slot.
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Icon(AppIcons.gift, size: 14, color: accent),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: card == null
              ? OutlinedButton(
                  onPressed: onJoin,
                  child: Text(s.joinCampaign),
                )
              : OutlinedButton.icon(
                  onPressed: onShowQr,
                  icon: const Icon(AppIcons.nfc, size: 18),
                  label: Text(s.nfcTapShort),
                ),
        ),
      ],
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

    final int balance = summaryAsync.maybeWhen(
      data: (CoinSummary sum) => sum.companies
          .where((CompanyBalance b) => b.companyId == company.id)
          .fold<int>(0, (int acc, CompanyBalance b) => acc + b.balance),
      orElse: () => 0,
    );

    return rewardsAsync.maybeWhen(
      data: (List<CoinReward> all) {
        // Owners also get their off-sale items; customers only see on-sale.
        final List<CoinReward> rewards =
            all.where((CoinReward r) => r.active).toList(growable: false);
        if (rewards.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: AppShadows.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: Text(s.buyWithCoin, style: AppTextStyles.h2)),
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
                        const Icon(AppIcons.token,
                            size: 16, color: AppColors.action),
                        const SizedBox(width: 4),
                        Text('$balance',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.action,
                              fontWeight: FontWeight.w800,
                            )),
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
                  affordable: balance >= r.coinCost,
                  onBuy: balance >= r.coinCost
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
            Text('Menyu', style: AppTextStyles.h2),
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
