// lib/src/widgets/reports/top_products_chart.dart
import 'package:andalus_smart_pos/src/utils/chart_formatters.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class TopProductsChart extends StatelessWidget {
  final List<TopSellingProduct> products;

  const TopProductsChart({super.key, required this.products});

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
              localizations.topSellingProducts,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: -45,
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: ChartFormatters.currencyFormat,
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),
                series: <CartesianSeries<TopSellingProduct, String>>[
                  BarSeries<TopSellingProduct, String>(
                    dataSource: products.take(10).toList(),
                    xValueMapper: (product, _) => product.name,
                    yValueMapper: (product, _) => product.revenue,
                    color: theme.colorScheme.primary,
                    width: 0.6,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.outer,
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
            if (products.isEmpty)
              Container(
                height: 200,
                alignment: Alignment.center,
                child: Text(
                  'No product data available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
