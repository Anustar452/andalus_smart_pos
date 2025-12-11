// lib/src/widgets/reports/advanced_product_analytics.dart
// Advanced product analytics widget displaying detailed product performance metrics.
// This includes ABC analysis and profit margin distribution charts.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class AdvancedProductAnalytics extends StatelessWidget {
  final ProductsReportData productsData;

  const AdvancedProductAnalytics({super.key, required this.productsData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ABC Analysis Chart
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ABC Analysis - Product Segmentation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    primaryYAxis: NumericAxis(
                      numberFormat: NumberFormat.percentPattern(),
                    ),
                    series: <CartesianSeries<ABCAnalysisData, String>>[
                      BarSeries<ABCAnalysisData, String>(
                        dataSource: _generateABCAnalysisData(),
                        xValueMapper: (data, _) => data.category,
                        yValueMapper: (data, _) => data.percentage,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Profit Margin Distribution
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profit Margin Distribution',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      PieSeries<MarginDistributionData, String>(
                        dataSource: _generateMarginDistributionData(),
                        xValueMapper: (data, _) => data.range,
                        yValueMapper: (data, _) => data.count,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<ABCAnalysisData> _generateABCAnalysisData() {
    return [
      ABCAnalysisData('A - High Value (20%)', 0.75),
      ABCAnalysisData('B - Medium Value (30%)', 0.20),
      ABCAnalysisData('C - Low Value (50%)', 0.05),
    ];
  }

  List<MarginDistributionData> _generateMarginDistributionData() {
    return [
      MarginDistributionData('0-10%', 5),
      MarginDistributionData('10-20%', 12),
      MarginDistributionData('20-30%', 25),
      MarginDistributionData('30-40%', 18),
      MarginDistributionData('40%+', 8),
    ];
  }
}

class ABCAnalysisData {
  final String category;
  final double percentage;

  ABCAnalysisData(this.category, this.percentage);
}

class MarginDistributionData {
  final String range;
  final int count;

  MarginDistributionData(this.range, this.count);
}
