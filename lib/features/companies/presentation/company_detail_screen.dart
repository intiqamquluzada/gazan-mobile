import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_card.dart';
import '../../loyalty/domain/loyalty_program.dart';
import '../../loyalty/presentation/widgets/loyalty_card_widget.dart';
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
          title: 'Xəta', subtitle: e.toString(),
          icon: Icons.error_outline_rounded,
        ),
        data: (Company? company) {
          if (company == null) {
            return const EmptyState(
              title: 'Tapılmadı',
              icon: Icons.search_off_rounded,
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

  LoyaltyCard? _cardFor(String programId) {
    return cardsAsync.maybeWhen(
      data: (List<LoyaltyCard> cards) {
        for (final LoyaltyCard c in cards) {
          if (c.programId == programId) return c;
        }
        return null;
      },
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color brand = Color(company.coverColorHex);
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar.large(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          expandedHeight: 220,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            title: Text(company.name,
                style: AppTextStyles.h2.copyWith(color: Colors.white)),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[brand, _darken(brand, 0.2)],
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              child: Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(company.logoEmoji,
                    style: const TextStyle(fontSize: 56)),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.huge,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed(<Widget>[
              _MetaRow(company: company),
              const SizedBox(height: AppSpacing.lg),
              Text(company.tagline,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  )),
              const SizedBox(height: AppSpacing.xxl),
              Text('Sadiqlik proqramları', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              programsAsync.when(
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: CircularProgressIndicator(),
                )),
                error: (Object e, _) => Text(e.toString()),
                data: (List<LoyaltyProgram> programs) {
                  if (programs.isEmpty) {
                    return const EmptyState(
                      title: 'Hələ proqram yoxdur',
                      subtitle: 'Bu obyekt tezliklə təklif əlavə edəcək.',
                      icon: Icons.card_giftcard_outlined,
                    );
                  }
                  return Column(
                    children: <Widget>[
                      for (final LoyaltyProgram p in programs) ...<Widget>[
                        LoyaltyCardWidget(
                          company: company,
                          program: p,
                          card: _cardFor(p.id),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(p.title, style: AppTextStyles.h3),
                              const SizedBox(height: AppSpacing.xs),
                              Text(p.description, style: AppTextStyles.bodySm),
                              const SizedBox(height: AppSpacing.lg),
                              if (_cardFor(p.id) == null)
                                PrimaryButton(
                                  label: 'Sadiqlik kartı al',
                                  icon: Icons.add_card_rounded,
                                  onPressed: () async {
                                    await ref
                                        .read(loyaltyActionsProvider)
                                        .joinProgram(p.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${company.name} kartı əlavə olundu'),
                                      ),
                                    );
                                  },
                                )
                              else
                                PrimaryButton(
                                  label: 'QR-i göstər',
                                  icon: Icons.qr_code_2_rounded,
                                  variant: PrimaryButtonVariant.tonal,
                                  onPressed: () => context.go('/qr'),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ],
                  );
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Color _darken(Color color, double amount) {
    final HSLColor hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _MetaChip(
          icon: Icons.star_rounded,
          label: company.rating.toStringAsFixed(1),
          subtitle: '${company.reviewCount} rəy',
          tint: AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.md),
        if (company.distanceKm != null)
          _MetaChip(
            icon: Icons.location_on_outlined,
            label: '${company.distanceKm!.toStringAsFixed(1)} km',
            subtitle: company.address.isEmpty ? 'Yaxınlıqda' : company.address,
            tint: AppColors.info,
          ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: tint),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label,
                      style: AppTextStyles.bodyLg
                          .copyWith(fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
