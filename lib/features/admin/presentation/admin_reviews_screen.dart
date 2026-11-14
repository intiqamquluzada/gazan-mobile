import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/empty_state.dart';

/// One row of the admin moderation list (`GET /api/v1/admin/reviews`).
class AdminReview {
  const AdminReview({
    required this.id,
    required this.rating,
    required this.userName,
    required this.companyId,
    required this.companyName,
    this.comment,
    this.createdAt,
    this.reportCount = 0,
  });

  final String id;
  final int rating;
  final String userName;
  final String companyId;
  final String companyName;
  final String? comment;
  final DateTime? createdAt;
  final int reportCount;

  factory AdminReview.fromJson(Map<String, dynamic> j) => AdminReview(
        id: j['id'] as String,
        rating: (j['rating'] as num?)?.toInt() ?? 0,
        userName: (j['userName'] as String?) ?? '—',
        companyId: (j['companyId'] as String?) ?? '',
        companyName: (j['companyName'] as String?) ?? '—',
        comment: j['comment'] as String?,
        createdAt: j['createdAt'] == null
            ? null
            : DateTime.tryParse(j['createdAt'] as String),
        reportCount: (j['reportCount'] as num?)?.toInt() ?? 0,
      );
}

/// All reviews, or with `true` only reported ones (most reported first).
final AutoDisposeFutureProviderFamily<List<AdminReview>, bool>
    _adminReviewsProvider =
    FutureProvider.autoDispose.family<List<AdminReview>, bool>(
        (Ref ref, bool reported) async {
  final List<dynamic> raw = await ref.read(apiClientProvider).get<List<dynamic>>(
      reported ? '/api/v1/admin/reviews?reported=true' : '/api/v1/admin/reviews');
  return raw
      .cast<Map<String, dynamic>>()
      .map(AdminReview.fromJson)
      .toList(growable: false);
});

/// Admin → Rəylər: newest reviews across every venue, filterable to low
/// ratings, each deletable (moderation).
class AdminReviewsScreen extends ConsumerStatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  ConsumerState<AdminReviewsScreen> createState() => _AdminReviewsState();
}

class _AdminReviewsState extends ConsumerState<AdminReviewsScreen> {
  bool _lowOnly = false;
  bool _reportedOnly = false;

  Future<void> _delete(AdminReview r) async {
    final S s = ref.read(sProvider);
    final bool ok = await showConfirmSheet(
      context,
      title: s.deleteReviewTitle,
      body: '${r.userName} → ${r.companyName}',
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok) return;
    try {
      await ref.read(apiClientProvider).delete('/api/v1/admin/reviews/${r.id}');
      ref.invalidate(_adminReviewsProvider(_reportedOnly));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${s.deleteFailed}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<AdminReview>> async =
        ref.watch(_adminReviewsProvider(_reportedOnly));
    final AppPalette p = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.reviewsWord),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/admin'),
        ),
        actions: <Widget>[
          FilterChip(
            label: Text(s.reportedFilter),
            selected: _reportedOnly,
            onSelected: (bool v) => setState(() => _reportedOnly = v),
          ),
          const SizedBox(width: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilterChip(
              label: Text(s.lowRatingsOnly),
              selected: _lowOnly,
              onSelected: (bool v) => setState(() => _lowOnly = v),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_adminReviewsProvider(_reportedOnly)),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => ListView(
            children: <Widget>[EmptyState(title: s.notLoaded, subtitle: '$e')],
          ),
          data: (List<AdminReview> all) {
            final List<AdminReview> list = _lowOnly
                ? all.where((AdminReview r) => r.rating <= 2).toList()
                : all;
            if (list.isEmpty) {
              return ListView(
                children: <Widget>[
                  EmptyState(
                    title: s.noReviewsYet,
                    icon: Icons.rate_review_outlined,
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext _, int i) {
                final AdminReview r = list[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: r.rating <= 2 || r.reportCount > 0
                          ? AppColors.danger.withValues(alpha: 0.35)
                          : p.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(r.companyName,
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ),
                          for (int k = 1; k <= 5; k++)
                            Icon(
                              k <= r.rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 14,
                              color: AppColors.reward,
                            ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.dangerText),
                            tooltip: s.delete,
                            onPressed: () => _delete(r),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(r.userName,
                                style: AppTextStyles.caption),
                          ),
                          if (r.reportCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.dangerSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(Icons.flag_rounded,
                                      size: 12, color: AppColors.dangerText),
                                  const SizedBox(width: 4),
                                  Text(s.reportCount(r.reportCount),
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.dangerText,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if ((r.comment ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(r.comment!, style: AppTextStyles.bodySm),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
