import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../promotions/presentation/widgets/promotions_carousel.dart';
import '../../promotions/presentation/widgets/stories_strip.dart';
import '../application/companies_providers.dart';
import '../domain/company.dart';
import 'widgets/category_chips.dart';
import 'widgets/company_card.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Company>> companies = ref.watch(companiesProvider);
    final String userName =
        ref.watch(currentUserProvider)?.fullName.split(' ').first ?? 'Dost';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(companiesProvider);
            ref.invalidate(featuredCompaniesProvider);
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(child: _Greeting(name: userName)),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: _SearchField(onChanged: (String v) {
                    ref.read(searchQueryProvider.notifier).state = v;
                  }),
                ),
              ),

              // ── Stories ──
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
              const SliverToBoxAdapter(child: StoriesStrip()),

              // ── Promotions / Reklamlar ──
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Reklamlar',
                    action: AppStrings.seeAll,
                    onAction: () {},
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              const SliverToBoxAdapter(child: PromotionsCarousel()),

              // ── Categories ──
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
              const SliverToBoxAdapter(child: CategoryChips()),

              // ── All places ──
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: Text('Bütün yerlər', style: AppTextStyles.h2),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              companies.when(
                data: (List<Company> list) {
                  if (list.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        title: 'Heç nə tapılmadı',
                        subtitle:
                            'Filtri dəyişməyi və ya başqa söz axtarmağı sına.',
                        icon: Icons.search_off_rounded,
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (BuildContext _, int i) => CompanyCard(
                        company: list[i],
                        onTap: () => context.push('/companies/${list[i].id}'),
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (Object e, _) => SliverFillRemaining(
                  child: EmptyState(
                    title: 'Xəta baş verdi',
                    subtitle: e.toString(),
                    icon: Icons.error_outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Salam, $name 👋', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text('Bu gün hardan qazansaq?', style: AppTextStyles.bodySm),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.notifications_none_rounded, size: 22),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: AppStrings.search,
        prefixIcon: Icon(Icons.search_rounded, size: 22),
      ),
    );
  }
}
