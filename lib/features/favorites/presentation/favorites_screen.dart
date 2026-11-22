import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../companies/domain/company.dart';
import '../../companies/presentation/widgets/company_card.dart';
import '../application/favorites_providers.dart';

/// Lists the businesses the customer has saved (hearted).
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<Company>> favorites =
        ref.watch(favoriteCompaniesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.favorites)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(favoriteCompaniesProvider),
        // Every state scrolls, so pull-to-refresh can retry a failed load.
        child: favorites.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              const SizedBox(height: 160),
              Center(
                child: Text(s.notLoaded, style: AppTextStyles.body),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(favoriteCompaniesProvider),
                  child: Text(s.retry),
                ),
              ),
            ],
          ),
          data: (List<Company> list) {
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const <Widget>[
                  SizedBox(height: 80),
                  _Empty(),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext context, int i) => CompanyCard(
                company: list[i],
                onTap: () => context.push('/companies/${list[i].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Empty extends ConsumerWidget {
  const _Empty();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.favorite_border_rounded,
                size: 56, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(s.noFavoritesYet, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              s.noFavoritesHint,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
