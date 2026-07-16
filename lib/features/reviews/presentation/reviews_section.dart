import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/reviews_providers.dart';
import '../data/reviews_repository.dart';
import '../domain/review.dart';

/// Ratings & reviews block for the company-detail screen.
class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  final String companyId;
  final String companyName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<CompanyReviews> async =
        ref.watch(companyReviewsProvider(companyId));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.md,
      ),
      child: async.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (Object e, _) =>
            Text(s.reviewsNotLoaded, style: AppTextStyles.bodySm),
        data: (CompanyReviews r) => _content(context, ref, s, r),
      ),
    );
  }

  Widget _content(
      BuildContext context, WidgetRef ref, S s, CompanyReviews r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(s.reviewsWord, style: AppTextStyles.h3),
            const Spacer(),
            if (r.count > 0) ...<Widget>[
              Text(r.average.toStringAsFixed(1),
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.textPrimary)),
              const SizedBox(width: 4),
              const Icon(Icons.star_rounded,
                  size: 20, color: AppColors.warning),
              const SizedBox(width: 4),
              Text('(${r.count})', style: AppTextStyles.bodySm),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (r.reviews.isEmpty)
          Text(s.noReviewsYet,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondary))
        else
          ...r.reviews.take(5).map((Review rev) => _ReviewTile(rev)),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: r.myReview == null ? s.writeReview : s.editReview,
            icon: Icons.rate_review_outlined,
            onPressed: () => _openWriteSheet(context, ref, r.myReview),
          ),
        ),
      ],
    );
  }

  void _openWriteSheet(
      BuildContext context, WidgetRef ref, Review? existing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (BuildContext _) => _WriteReviewSheet(
        companyId: companyId,
        companyName: companyName,
        existing: existing,
      ),
    );
  }
}

class _ReviewTile extends ConsumerWidget {
  const _ReviewTile(this.review);

  final Review review;

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  review.mine
                      ? '${review.userName} (${s.youParen})'
                      : review.userName,
                  style: AppTextStyles.bodySm
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _Stars(rating: review.rating, size: 14),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(review.comment!, style: AppTextStyles.bodySm),
          ],
          const SizedBox(height: 2),
          Text(_date(review.createdAt), style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 18});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        5,
        (int i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: AppColors.warning,
        ),
      ),
    );
  }
}

class _WriteReviewSheet extends ConsumerStatefulWidget {
  const _WriteReviewSheet({
    required this.companyId,
    required this.companyName,
    this.existing,
  });

  final String companyId;
  final String companyName;
  final Review? existing;

  @override
  ConsumerState<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<_WriteReviewSheet> {
  late int _rating;
  late final TextEditingController _comment;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating ?? 0;
    _comment = TextEditingController(text: widget.existing?.comment ?? '');
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(sProvider).atLeastOneStar)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(reviewsRepositoryProvider).submit(
            companyId: widget.companyId,
            rating: _rating,
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
          );
      ref.invalidate(companyReviewsProvider(widget.companyId));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(sProvider).reviewThanks)),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final EdgeInsets bottom = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: bottom,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
            Text(widget.companyName, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(s.rateExperience,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(
                  5,
                  (int i) => IconButton(
                    onPressed: () => setState(() => _rating = i + 1),
                    icon: Icon(
                      i < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 40,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _comment,
              maxLines: 4,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: s.reviewHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: s.sendAction,
              icon: Icons.check_rounded,
              loading: _saving,
              onPressed: _saving ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
