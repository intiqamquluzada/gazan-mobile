import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/company_logo.dart';
import '../../../companies/application/companies_providers.dart';
import '../../../companies/domain/company.dart';
import '../../application/promotions_providers.dart';
import '../../domain/story.dart';

/// Horizontal row of circular brand bubbles that open the story viewer.
class StoriesStrip extends ConsumerWidget {
  const StoriesStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<StoryGroup>> groupsAsync =
        ref.watch(storyGroupsProvider);

    return SizedBox(
      height: 110,
      child: groupsAsync.when(
        loading: () => const _StripSkeleton(),
        error: (_, __) => const SizedBox.shrink(),
        data: (List<StoryGroup> groups) {
          if (groups.isEmpty) return const SizedBox.shrink();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (BuildContext _, int i) =>
                _StoryBubble(group: groups[i]),
          );
        },
      ),
    );
  }
}

class _StoryBubble extends ConsumerWidget {
  const _StoryBubble({required this.group});

  final StoryGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Company?> companyAsync =
        ref.watch(companyByIdProvider(group.companyId));
    final Set<String> viewed = ref.watch(viewedStoryGroupsProvider);
    final bool seen = viewed.contains(group.companyId);

    return companyAsync.when(
      loading: () => const _BubbleSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (Company? c) {
        if (c == null) return const SizedBox.shrink();
        final Color brand = Color(c.coverColorHex);
        return InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () {
            ref
                .read(viewedStoryGroupsProvider.notifier)
                .update((Set<String> s) => <String>{...s, group.companyId});
            context.push('/stories/${group.companyId}');
          },
          child: SizedBox(
            width: 76,
            child: Column(
              children: <Widget>[
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: seen
                        ? null
                        : LinearGradient(
                            colors: <Color>[brand, AppColors.primary],
                          ),
                    border: seen
                        ? Border.all(color: AppColors.border, width: 2)
                        : null,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: CompanyLogo(
                        name: c.name,
                        brandColor: brand,
                        size: 60,
                        radius: 999,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.name,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StripSkeleton extends StatelessWidget {
  const _StripSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (_, __) => const _BubbleSkeleton(),
    );
  }
}

class _BubbleSkeleton extends StatelessWidget {
  const _BubbleSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: <Widget>[
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 48,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
