import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// One line of a [TrendLineChart].
class TrendSeries {
  const TrendSeries({
    required this.label,
    required this.values,
    required this.color,
  });

  final String label;
  final List<num> values;
  final Color color;
}

/// Compact daily-trend line chart shared by the business and admin panels.
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.series,
    required this.xLabels,
    this.height = 200,
  });

  final List<TrendSeries> series;

  /// One short label per point; only a few are drawn.
  final List<String> xLabels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final num top = series
        .expand((TrendSeries t) => t.values)
        .fold<num>(0, (num a, num b) => math.max(a, b));
    final double maxY = top <= 0 ? 4 : (top * 1.2).ceilToDouble();
    final double step = math.max(1, xLabels.length / 5).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (series.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 16,
              children: <Widget>[
                for (final TrendSeries t in series)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(width: 10, height: 10, color: t.color),
                      const SizedBox(width: 6),
                      Text(t.label, style: AppTextStyles.caption),
                    ],
                  ),
              ],
            ),
          ),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: math.max(1, (maxY / 4).ceilToDouble()),
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: p.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    interval: math.max(1, (maxY / 4).ceilToDouble()),
                    getTitlesWidget: (double v, TitleMeta _) => Text(
                      v.toInt().toString(),
                      style: AppTextStyles.caption
                          .copyWith(color: p.textTertiary),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: step,
                    getTitlesWidget: (double v, TitleMeta _) {
                      final int i = v.toInt();
                      if (i < 0 || i >= xLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          xLabels[i],
                          style: AppTextStyles.caption
                              .copyWith(color: p.textTertiary),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: <LineChartBarData>[
                for (final TrendSeries t in series)
                  LineChartBarData(
                    spots: <FlSpot>[
                      for (int i = 0; i < t.values.length; i++)
                        FlSpot(i.toDouble(), t.values[i].toDouble()),
                    ],
                    color: t.color,
                    barWidth: 2.5,
                    isCurved: false,
                    dotData: FlDotData(show: t.values.length <= 14),
                    belowBarData: BarAreaData(
                      show: series.length == 1,
                      color: t.color.withValues(alpha: 0.12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// "YYYY-MM-DD" → "DD.MM" for chart axes.
String shortDay(String iso) {
  final List<String> p = iso.split('-');
  return p.length == 3 ? '${p[2]}.${p[1]}' : iso;
}
