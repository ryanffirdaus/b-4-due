import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell.dart';
import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bills/domain/bill_category.dart';
import '../../bills/presentation/bill_labels.dart';
import '../../bills/presentation/widgets/subscription_card.dart';
import '../../payments/domain/payment.dart';
import '../domain/insights.dart';

/// Colours for the category chart: the brand blue first, then calm tones
/// from the spec palette.
List<Color> _chartColors(Palette p) => [
  p.primary,
  const Color(0xFF375390),
  p.success,
  p.warning,
  const Color(0xFF8B5CF6),
  p.today,
  const Color(0xFF14B8A6),
  p.muted,
];

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final theme = Theme.of(context);
    final p = context.palette;
    final today = ref.watch(todayProvider);
    final bills = ref.watch(activeBillsProvider).value ?? const [];
    final history =
        ref.watch(paymentHistoryProvider).value ?? const <PaymentEntry>[];
    final stats = spendingStats(
      bills: bills,
      payments: [for (final e in history) e.payment],
      today: today,
    );

    Widget card({required String title, required Widget child}) => Padding(
      padding: const EdgeInsets.only(bottom: Tokens.cardGap),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: Tokens.sectionGap),
          children: [
            TabTitle(l10n.navStatistics),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Tokens.pagePadding,
                vertical: 8,
              ),
              child: stats.isEmpty
                  ? Text(
                      l10n.statsEmpty,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: p.textSecondary,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        card(
                          title: l10n.statsAverage,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                format.rupiah(stats.averageMonthly),
                                style: theme.textTheme.displayMedium,
                              ),
                              Text(
                                l10n.statsAverageHelp,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        card(
                          title: l10n.statsUpcoming,
                          child: Text(
                            l10n.statsUpcomingValue(
                              stats.upcomingCount,
                              format.rupiah(stats.upcomingTotal),
                            ),
                            style: theme.textTheme.headlineMedium,
                          ),
                        ),
                        if (stats.mostExpensive case final top?)
                          card(
                            title: l10n.statsMostExpensive,
                            child: Row(
                              children: [
                                CategoryLogo(bill: top, size: 44),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        top.name,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      Text(
                                        l10n.statsPerMonth(
                                          format.rupiah(
                                            stats.mostExpensiveMonthly,
                                          ),
                                        ),
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (stats.byCategory.isNotEmpty)
                          card(
                            title: l10n.statsByCategory,
                            child: _CategoryChart(stats: stats),
                          ),
                        card(
                          title: l10n.statsMonthlyPaid,
                          child: _MonthlyBars(stats: stats),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.stats});

  final SpendingStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = context.formatters;
    final p = context.palette;
    final colors = _chartColors(p);
    final total = stats.byCategory.fold<int>(0, (sum, e) => sum + e.value);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 48,
              sectionsSpace: 2,
              sections: [
                for (var i = 0; i < stats.byCategory.length; i++)
                  PieChartSectionData(
                    value: stats.byCategory[i].value.toDouble(),
                    color: colors[i % colors.length],
                    radius: 36,
                    showTitle: false,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < stats.byCategory.length; i++)
          _CategoryRow(
            color: colors[i % colors.length],
            category: stats.byCategory[i].key,
            label: stats.byCategory[i].key.label(l10n),
            amount: format.rupiah(stats.byCategory[i].value),
            percent: total == 0
                ? ''
                : '${(stats.byCategory[i].value * 100 / total).round()}%',
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.color,
    required this.category,
    required this.label,
    required this.amount,
    required this.percent,
  });

  final Color color;
  final BillCategory category;
  final String label;
  final String amount;
  final String percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          Text(amount, style: theme.textTheme.titleSmall),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              percent,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyBars extends StatelessWidget {
  const _MonthlyBars({required this.stats});

  final SpendingStats stats;

  @override
  Widget build(BuildContext context) {
    final format = context.formatters;
    final theme = Theme.of(context);
    final p = context.palette;
    final maxY = stats.monthlyPaid
        .map((e) => e.value)
        .fold<int>(0, (a, b) => a > b ? a : b)
        .toDouble();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 1 : maxY * 1.15,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => p.navy,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                format.rupiah(rod.toY.round()),
                const TextStyle(color: Colors.white),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= stats.monthlyPaid.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      format.shortMonth(stats.monthlyPaid[i].key),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < stats.monthlyPaid.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: stats.monthlyPaid[i].value.toDouble(),
                    width: 22,
                    color: i == stats.monthlyPaid.length - 1
                        ? p.primary
                        : p.primary.withValues(alpha: 0.45),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
