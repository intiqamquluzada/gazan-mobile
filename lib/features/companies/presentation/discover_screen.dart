import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/hero_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../../promotions/presentation/widgets/promotions_carousel.dart';
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

    // Keep the last loaded list visible while a new query is fetching so
    // the feed never collapses into a spinner under the search field.
    final List<Company>? list = companies.valueOrNull;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(companiesProvider);
          ref.invalidate(featuredCompaniesProvider);
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: HeroHeader(
                title: 'Salam, $userName',
                subtitle: 'Bu gün hardan qazanaq?',
                actions: const <Widget>[
                  NotificationBell(),
                ],
                bottom: const _SearchField(),
              ),
            ),

            // ── Promotions ──
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
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Bütün yerlər', style: AppTextStyles.h2),
                    ),
                    if (companies.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            _resultsSliver(context, companies, list),
          ],
        ),
      ),
    );
  }

  Widget _resultsSliver(
    BuildContext context,
    AsyncValue<List<Company>> companies,
    List<Company>? list,
  ) {
    if (list == null && companies.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (list == null && companies.hasError) {
      return SliverFillRemaining(
        child: EmptyState(
          title: 'Xəta baş verdi',
          subtitle: companies.error.toString(),
          icon: AppIcons.error,
        ),
      );
    }
    final List<Company> items = list ?? const <Company>[];
    if (items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          title: 'Heç nə tapılmadı',
          subtitle: 'Filtri dəyişməyi və ya başqa söz axtarmağı sına.',
          icon: AppIcons.searchOff,
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (BuildContext _, int i) => CompanyCard(
          company: items[i],
          onTap: () => context.push('/companies/${items[i].id}'),
        ),
      ),
    );
  }
}

/// White pill search field designed to sit on the violet hero band.
///
/// Owns its controller and debounces input so the feed query updates
/// after the user pauses typing — the field keeps focus across the
/// parent rebuilds the new results trigger.
class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final String q = value.trim();
      if (q != ref.read(searchQueryProvider)) {
        ref.read(searchQueryProvider.notifier).state = q;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: AppStrings.search,
          hintStyle:
              AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          prefixIcon: const Icon(AppIcons.search,
              size: 22, color: AppColors.textTertiary),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (BuildContext _, TextEditingValue v, __) {
              if (v.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(AppIcons.close,
                    size: 18, color: AppColors.textTertiary),
                onPressed: () {
                  _controller.clear();
                  _debounce?.cancel();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              );
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
