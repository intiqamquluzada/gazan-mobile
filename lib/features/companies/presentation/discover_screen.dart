import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/hero_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../../promotions/application/promotions_providers.dart';
import '../../promotions/presentation/widgets/promotions_carousel.dart';
import '../application/companies_providers.dart';
import '../domain/company.dart';
import 'widgets/category_chips.dart';
import 'widgets/company_card.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<Company>> companies = ref.watch(companiesProvider);
    final String firstName = (ref.watch(currentUserProvider)?.fullName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .first;
    final String userName = firstName.isEmpty ? s.friendFallback : firstName;

    // Keep the last loaded list visible while a new query is fetching so
    // the feed never collapses into a spinner under the search field.
    final List<Company>? list = companies.valueOrNull;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(companiesProvider);
          ref.invalidate(featuredCompaniesProvider);
          ref.invalidate(promotionsProvider);
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  HeroHeader(
                    title: '${s.helloName}, $userName',
                    subtitle: s.whereEarnToday,
                    bottomInset: AppSpacing.xxl,
                    actions: const <Widget>[
                      NotificationBell(),
                    ],
                  ),
                  // Floats half on/half off the hero band's bottom edge —
                  // reads far lighter than a search field boxed fully
                  // inside the colour block.
                  const Positioned(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: -22,
                    child: _SearchField(),
                  ),
                ],
              ),
            ),

            // ── Promotions ──
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(title: s.promotions),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            const SliverToBoxAdapter(child: PromotionsCarousel()),

            // ── All places ──
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(s.allPlaces, style: AppTextStyles.h2),
                    ),
                    if (companies.isLoading) ...<Widget>[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    const CategoryButton(),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            _resultsSliver(context, s, companies, list),
          ],
        ),
      ),
    );
  }

  Widget _resultsSliver(
    BuildContext context,
    S s,
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
        child: ErrorState(error: companies.error!),
      );
    }
    final List<Company> items = list ?? const <Company>[];
    if (items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          title: s.nothingFound,
          subtitle: s.nothingFoundHint,
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
    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: AppShadows.md,
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        style:
            AppTextStyles.bodySm.copyWith(color: context.palette.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: ref.watch(sProvider).search,
          hintStyle: AppTextStyles.bodySm
              .copyWith(color: context.palette.textTertiary),
          prefixIcon:
              Icon(AppIcons.search, size: 19, color: AppColors.caramel),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 44, minHeight: 20),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (BuildContext _, TextEditingValue v, __) {
              if (v.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(AppIcons.close,
                    size: 16, color: AppColors.textTertiary),
                onPressed: () {
                  _controller.clear();
                  _debounce?.cancel();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              );
            },
          ),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 36, minHeight: 20),
          filled: true,
          fillColor: context.palette.surface,
          contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
