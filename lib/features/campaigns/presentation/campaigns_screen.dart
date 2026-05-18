import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';

/// The three campaign types a business can run:
///  • [stamp]    — classic loyalty card (N visits → reward)
///  • [redeem]   — spend collected coins for an item
///  • [cashback] — use coins as a cash discount at the register
enum CampaignType { stamp, redeem, cashback }

class Campaign {
  const Campaign({
    required this.business,
    required this.title,
    required this.type,
    required this.accent,
    required this.icon,
    this.stampsDone = 0,
    this.stampsNeeded = 0,
    this.coinCost = 0,
  });

  final String business;
  final String title;
  final CampaignType type;
  final Color accent;
  final IconData icon;
  final int stampsDone;
  final int stampsNeeded;
  final int coinCost;
}

/// Kampaniyalar — every active offer the customer can take part in.
/// Demo data until the backend campaign endpoints land.
class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  static const List<Campaign> _items = <Campaign>[
    Campaign(
      business: 'Reynline Coffee',
      title: 'Hər 6 qəhvəyə 1 pulsuz',
      type: CampaignType.stamp,
      accent: AppColors.primary,
      icon: AppIcons.cafe,
      stampsDone: 4,
      stampsNeeded: 6,
    ),
    Campaign(
      business: 'Sweet House',
      title: 'Hər 5 alışa 1 şirniyyat',
      type: CampaignType.stamp,
      accent: AppColors.accent,
      icon: AppIcons.bakery,
      stampsDone: 2,
      stampsNeeded: 5,
    ),
    Campaign(
      business: 'Sweet House',
      title: '800 coin = 1 dilim tort',
      type: CampaignType.redeem,
      accent: AppColors.accent,
      icon: AppIcons.gift,
      coinCost: 800,
    ),
    Campaign(
      business: 'İstənilən yer',
      title: 'Coinləri kassada nağd endirim kimi işlət',
      type: CampaignType.cashback,
      accent: Color(0xFF12B5A6),
      icon: AppIcons.token,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kampaniyalar')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (BuildContext _, int i) =>
            _CampaignCard(campaign: _items[i]),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign});

  final Campaign campaign;

  String get _typeLabel => switch (campaign.type) {
        CampaignType.stamp => 'Sadiqlik kartı',
        CampaignType.redeem => 'Coinlə al',
        CampaignType.cashback => 'Nağd endirim',
      };

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: dark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: dark ? null : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: campaign.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(campaign.icon, color: campaign.accent, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(campaign.title, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(campaign.business, style: AppTextStyles.bodySm),
                  ],
                ),
              ),
              _TypeBadge(label: _typeLabel, color: campaign.accent),
            ],
          ),
          if (campaign.type == CampaignType.stamp) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            _StampRow(
              done: campaign.stampsDone,
              total: campaign.stampsNeeded,
              accent: campaign.accent,
            ),
          ],
          if (campaign.type == CampaignType.redeem) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                const Icon(AppIcons.token,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('${campaign.coinCost} coin',
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StampRow extends StatelessWidget {
  const _StampRow({
    required this.done,
    required this.total,
    required this.accent,
  });

  final int done;
  final int total;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int i = 0; i < total; i++) ...<Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: i < done
                          ? accent
                          : accent.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      i < done ? AppIcons.check : AppIcons.star,
                      size: 16,
                      color: i < done ? Colors.white : accent,
                    ),
                  ),
                ),
              ),
              if (i != total - 1) const SizedBox(width: 6),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('$done / $total',
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            )),
      ],
    );
  }
}
