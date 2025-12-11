// lib/src/widgets/reports/financial_ratios_section.dart
// Financial ratios widget displaying key financial metrics and break-even analysis charts.
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class FinancialRatiosSection extends StatelessWidget {
  final FinancialReportData financialData;

  const FinancialRatiosSection({super.key, required this.financialData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Key Financial Ratios
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Financial Ratios',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    primaryYAxis: NumericAxis(),
                    series: <CartesianSeries<FinancialRatio, String>>[
                      BarSeries<FinancialRatio, String>(
                        dataSource: _generateFinancialRatios(),
                        xValueMapper: (data, _) => data.ratio,
                        yValueMapper: (data, _) => data.value,
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

        // Break-Even Analysis
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Break-Even Analysis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(text: 'Amount (ETB)'),
                    ),
                    series: <CartesianSeries<BreakEvenData, String>>[
                      LineSeries<BreakEvenData, String>(
                        dataSource: _generateBreakEvenData(),
                        xValueMapper: (data, _) => data.month,
                        yValueMapper: (data, _) => data.revenue,
                        name: 'Revenue',
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                      LineSeries<BreakEvenData, String>(
                        dataSource: _generateBreakEvenData(),
                        xValueMapper: (data, _) => data.month,
                        yValueMapper: (data, _) => data.costs,
                        name: 'Total Costs',
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                    ],
                    legend: Legend(isVisible: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FinancialRatio> _generateFinancialRatios() {
    return [
      FinancialRatio('Gross Margin', 35.2),
      FinancialRatio('Net Margin', 22.8),
      FinancialRatio('ROI', 18.5),
      FinancialRatio('Current Ratio', 2.1),
      FinancialRatio('Quick Ratio', 1.5),
    ];
  }

  List<BreakEvenData> _generateBreakEvenData() {
    return [
      BreakEvenData('Jan', 80000, 95000),
      BreakEvenData('Feb', 95000, 92000),
      BreakEvenData('Mar', 110000, 98000),
      BreakEvenData('Apr', 125000, 105000),
      BreakEvenData('May', 140000, 110000),
      BreakEvenData('Jun', 155000, 115000),
    ];
  }
}

class FinancialRatio {
  final String ratio;
  final double value;

  FinancialRatio(this.ratio, this.value);
}

class BreakEvenData {
  final String month;
  final double revenue;
  final double costs;

  BreakEvenData(this.month, this.revenue, this.costs);
}
