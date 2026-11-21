import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/trend_line_chart.dart';
import '../application/panel_providers.dart';
import '../domain/panel_models.dart';

/// Owner → how the program is doing over the last 7, 30 or 90 days.
class BusinessAnalyticsScreen extends ConsumerStatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  ConsumerState<BusinessAnalyticsScreen> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<BusinessAnalyticsScreen> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<BusinessAnalytics> data =
        ref.watch(businessAnalyticsProvider(_days));
    return Scaffold(
      appBar: AppBar(title: Text(s.analyticsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: <Widget>[
          SegmentedButton<int>(
            segments: <ButtonSegment<int>>[
              for (final int d in const <int>[7, 30, 90])
                ButtonSegment<int>(value: d, label: Text('$d ${s.daysWord}')),
            ],
            selected: <int>{_days},
            onSelectionChanged: (Set<int> v) =>
                setState(() => _days = v.first),
          ),
          const SizedBox(height: AppSpacing.xl),
          data.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object e, _) =>
                EmptyState(title: s.notLoaded, subtitle: '$e'),
            data: (BusinessAnalytics a) => _Body(a: a, s: s),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.a, required this.s});

  final BusinessAnalytics a;
  final S s;

  @override
  Widget build(BuildContext context) {
    final List<(String, int)> tiles = <(String, int)>[
      (s.anNewCustomers, a.newCustomers),
      (s.anActiveCustomers, a.activeCustomers),
      (s.anReturning, a.returningCustomers),
      (s.anStamps, a.stamps),
      (s.anRewards, a.rewardsClaimed),
      (s.anCoinsEarned, a.coinsEarned),
      (s.anCoinsSpent, a.coinsSpent),
      (s.anNfcAccepted, a.nfcAccepted),
      (s.anNfcRejected, a.nfcRejected),
    ];
    final AppPalette p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext _, BoxConstraints c) {
            final int columns = c.maxWidth >= 700 ? 5 : 3;
            const double gap = AppSpacing.sm;
            final double w = (c.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (final (String label, int value) in tiles)
                  Container(
                    width: w,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: p.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('$value', style: AppTextStyles.h2),
                        Text(label,
                            maxLines: 2,
                            style: AppTextStyles.caption
                                .copyWith(color: p.textSecondary)),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(s.anDailyTrend, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        TrendLineChart(
          xLabels: <String>[
            for (final DailyPoint d in a.daily) shortDay(d.date),
          ],
          series: <TrendSeries>[
            TrendSeries(
              label: s.anStamps,
              color: AppColors.caramel,
              values: <num>[for (final DailyPoint d in a.daily) d.stamps],
            ),
            TrendSeries(
              label: s.anRewards,
              color: AppColors.success,
              values: <num>[for (final DailyPoint d in a.daily) d.rewards],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(s.anPrograms, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        if (a.programs.isEmpty)
          Text(s.anNoPrograms, style: AppTextStyles.bodySm)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: <DataColumn>[
                DataColumn(label: Text(s.campaigns)),
                DataColumn(label: Text(s.anMembers), numeric: true),
                DataColumn(label: Text(s.anCompleted), numeric: true),
                DataColumn(label: Text(s.anRedeemed), numeric: true),
              ],
              rows: <DataRow>[
                for (final ProgramPerformance x in a.programs)
                  DataRow(cells: <DataCell>[
                    DataCell(Text(x.title)),
                    DataCell(Text('${x.members}')),
                    DataCell(Text('${x.completed}')),
                    DataCell(Text('${x.redeemed}')),
                  ]),
              ],
            ),
          ),
      ],
    );
  }
}
