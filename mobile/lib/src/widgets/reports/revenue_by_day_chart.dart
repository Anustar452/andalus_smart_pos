// lib/src/widgets/reports/revenue_by_day_chart.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../localization/app_localizations.dart';
import '../common/custom_card.dart';

class RevenueByDayChart extends StatelessWidget {
  final Map<String, double> revenueByDay;

  const RevenueByDayChart({super.key, required this.revenueByDay});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final chartData = _getOrderedChartData();

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.revenueByDay,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.currency(symbol: 'ETB '),
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),
                series: <CartesianSeries<_ChartData, String>>[
                  ColumnSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (data, _) => data.x,
                    yValueMapper: (data, _) => data.y,
                    color: theme.colorScheme.secondary,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: theme.textTheme.bodySmall,
                    ),
                    animationDuration: 1000,
                  )
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x : ETB point.y',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ChartData> _getOrderedChartData() {
    const dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayOrder
        .map(
            (day) => _ChartData(_getFullDayName(day), revenueByDay[day] ?? 0.0))
        .toList();
  }

  String _getFullDayName(String shortDay) {
    switch (shortDay) {
      case 'Mon':
        return 'Monday';
      case 'Tue':
        return 'Tuesday';
      case 'Wed':
        return 'Wednesday';
      case 'Thu':
        return 'Thursday';
      case 'Fri':
        return 'Friday';
      case 'Sat':
        return 'Saturday';
      case 'Sun':
        return 'Sunday';
      default:
        return shortDay;
    }
  }
}

class _ChartData {
  final String x;
  final double y;

  _ChartData(this.x, this.y);
}
