// lib/src/widgets/reports/sales_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../localization/app_localizations.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';

class SalesTrendChart extends StatelessWidget {
  final List<DailySalesData> dailySales;

  const SalesTrendChart({super.key, required this.dailySales});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.dailySalesTrend,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: dailySales.isNotEmpty
                  ? SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat('MMM dd'),
                        majorGridLines: const MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        numberFormat:
                            NumberFormat.compactCurrency(symbol: 'ETB '),
                        majorGridLines: const MajorGridLines(width: 0.5),
                      ),
                      series: <CartesianSeries<DailySalesData, DateTime>>[
                        LineSeries<DailySalesData, DateTime>(
                          dataSource: dailySales,
                          xValueMapper: (data, _) => data.date,
                          yValueMapper: (data, _) => data.amount,
                          color: theme.colorScheme.primary,
                          width: 3,
                          markerSettings: const MarkerSettings(isVisible: true),
                          animationDuration: 1000,
                        )
                      ],
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        format: 'point.x : ETB point.y',
                      ),
                    )
                  : Center(
                      child: Text(
                        'No sales data available for the selected period',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
