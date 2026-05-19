import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/company_logo.dart';
import '../../../core/widgets/empty_state.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_card.dart';
import '../../loyalty/domain/loyalty_program.dart';
import '../application/companies_providers.dart';
import '../domain/company.dart';

class CompanyDetailScreen extends ConsumerWidget {
  const CompanyDetailScreen({super.key, required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Company?> companyAsync =
        ref.watch(companyByIdProvider(companyId));
    final AsyncValue<List<LoyaltyProgram>> programsAsync =
        ref.watch(programsForCompanyProvider(companyId));
    final AsyncValue<List<LoyaltyCard>> cardsAsync =
        ref.watch(myCardsProvider);

    return Scaffold(
      body: companyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: 'Xəta',
          subtitle: e.toString(),
          icon: AppIcons.error,
        ),
        data: (Company? company) {
          if (company == null) {
            return const EmptyState(
              title: 'Tapılmadı',
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
    final Color brand = Color(company.coverColorHex);
    final double topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      children: <Widget>[
        ListView(
          padding: EdgeInsets.zero,
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
                      cardFor: _cardFor,
                      onJoin: (LoyaltyProgram p) async {
                        await ref
                            .read(loyaltyActionsProvider)
                            .joinProgram(p.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${company.name} kartı əlavə olundu'),
                          ),
                        );
                      },
                      onShowQr: () => context.go('/qr'),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
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
              const _GlassCircle(icon: AppIcons.heart),
              const SizedBox(width: AppSpacing.sm),
              const _GlassCircle(icon: AppIcons.share),
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
              brandColor: Colors.white,
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
                    color: Colors.white.withValues(alpha: on ? 1 : 0.5),
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
    return h
        .withLightness((h.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 19, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.company});

  final Company company;

  static const List<_Amenity> _amenities = <_Amenity>[
    _Amenity('WIFI', 'Wifi', Icons.wifi_rounded),
    _Amenity('WORKSPACE', 'Çalışma', Icons.laptop_mac_rounded),
    _Amenity('MEETING', 'Toplantı', Icons.groups_rounded),
    _Amenity('GARDEN', 'Bağça', Icons.park_rounded),
    _Amenity('PARKING', 'Avtopark', Icons.local_parking_rounded),
    _Amenity('VEGAN', 'Vegan', Icons.eco_rounded),
    _Amenity('PET', 'Pet', Icons.pets_rounded),
  ];

  @override
  Widget build(BuildContext context) {
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
                        company.category.label,
                      ].join(' • '),
                      style: AppTextStyles.bodySm,
                    ),
                    if ((company.workingHours ?? '').isNotEmpty ||
                        (company.phone ?? '').isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          if ((company.workingHours ?? '').isNotEmpty) ...<Widget>[
                            const Icon(AppIcons.clock,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(company.workingHours!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
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
              _RoundAction(icon: AppIcons.star, label: company.rating
                  .toStringAsFixed(1)),
              const SizedBox(width: 6),
              _RoundAction(icon: AppIcons.location),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final _Amenity a in _amenities) ...<Widget>[
                  _AmenityChip(
                    amenity: a,
                    active: company.amenities.contains(a.code),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, this.label});

  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: label == null ? 0 : 12),
      width: label == null ? 40 : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        shape: label == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            label == null ? null : BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          if (label != null) ...<Widget>[
            const SizedBox(width: 4),
            Text(label!,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ],
      ),
    );
  }
}

class _Amenity {
  const _Amenity(this.code, this.label, this.icon);
  final String code;
  final String label;
  final IconData icon;
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.amenity, required this.active});

  final _Amenity amenity;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final bool on = active;
    return Column(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.primarySoft : AppColors.surfaceAlt,
            shape: BoxShape.circle,
          ),
          child: Icon(
            amenity.icon,
            size: 22,
            color: on ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          amenity.label,
          style: AppTextStyles.caption.copyWith(
            color: on ? AppColors.primary : AppColors.textTertiary,
            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OffersCard extends StatelessWidget {
  const _OffersCard({
    required this.company,
    required this.programsAsync,
    required this.cardFor,
    required this.onJoin,
    required this.onShowQr,
  });

  final Company company;
  final AsyncValue<List<LoyaltyProgram>> programsAsync;
  final LoyaltyCard? Function(String programId) cardFor;
  final Future<void> Function(LoyaltyProgram program) onJoin;
  final VoidCallback onShowQr;

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: _BigButton(
                  label: 'Menyu',
                  icon: Icons.restaurant_menu_rounded,
                  filled: false,
                  onTap: () {
                    final String? url = company.menuUrl;
                    if (url == null || url.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Menyu hələ əlavə olunmayıb')),
                      );
                      return;
                    }
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext ctx) => AlertDialog(
                        title: const Text('Menyu'),
                        content: SelectableText(url),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Bağla'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _BigButton(
                  label: 'QR göstər',
                  icon: AppIcons.qr,
                  filled: true,
                  onTap: onShowQr,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.lg),
          Text('Kampaniyalar', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          programsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object e, _) => Text(e.toString()),
            data: (List<LoyaltyProgram> programs) {
              if (programs.isEmpty) {
                return const EmptyState(
                  title: 'Hələ kampaniya yoxdur',
                  subtitle: 'Bu obyekt tezliklə təklif əlavə edəcək.',
                  icon: AppIcons.gift,
                );
              }
              return Column(
                children: <Widget>[
                  for (int i = 0; i < programs.length; i++) ...<Widget>[
                    _CampaignRow(
                      program: programs[i],
                      card: cardFor(programs[i].id),
                      accent: i.isEven
                          ? AppColors.primary
                          : AppColors.accent,
                      onJoin: () => onJoin(programs[i]),
                      onShowQr: onShowQr,
                    ),
                    if (i != programs.length - 1) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
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
    final Color fg = filled ? Colors.white : AppColors.primary;
    return Material(
      color: filled ? AppColors.primary : AppColors.primarySoft,
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
              Text(label,
                  style: AppTextStyles.button.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampaignRow extends StatelessWidget {
  const _CampaignRow({
    required this.program,
    required this.card,
    required this.accent,
    required this.onJoin,
    required this.onShowQr,
  });

  final LoyaltyProgram program;
  final LoyaltyCard? card;
  final Color accent;
  final VoidCallback onJoin;
  final VoidCallback onShowQr;

  @override
  Widget build(BuildContext context) {
    final int total = program.stampsRequired;
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
                  Text(program.rewardLabel, style: AppTextStyles.bodySm),
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
                      color: s < done
                          ? accent
                          : accent.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      s < done ? AppIcons.check : program.rewardType.icon,
                      size: 14,
                      color: s < done ? Colors.white : accent,
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
                  child: const Text('Kampaniyaya qoşul'),
                )
              : OutlinedButton.icon(
                  onPressed: onShowQr,
                  icon: const Icon(AppIcons.qr, size: 18),
                  label: const Text('QR göstər'),
                ),
        ),
      ],
    );
  }
}
