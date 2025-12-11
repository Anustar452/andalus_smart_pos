// lib/src/widgets/reports/customer_analytics_section.dart
// Customer analytics widget displaying customer behavior and lifetime value metrics.
// This includes customer lifetime value and churn risk analysis charts.
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class CustomerAnalyticsSection extends StatelessWidget {
  final CustomersReportData customersData;

  const CustomerAnalyticsSection({super.key, required this.customersData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Customer Lifetime Value
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Lifetime Value Analysis',
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
                      title: AxisTitle(text: 'Lifetime Value (ETB)'),
                    ),
                    series: <CartesianSeries<LTVData, String>>[
                      BarSeries<LTVData, String>(
                        dataSource: _generateLTVData(),
                        xValueMapper: (data, _) => data.segment,
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

        // Churn Risk Analysis
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Churn Risk Analysis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      DoughnutSeries<ChurnData, String>(
                        dataSource: _generateChurnData(),
                        xValueMapper: (data, _) => data.risk,
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
      ],
    );
  }

  List<LTVData> _generateLTVData() {
    return [
      LTVData('High Value', 12500),
      LTVData('Medium Value', 6500),
      LTVData('Low Value', 1800),
      LTVData('New Customers', 500),
    ];
  }

  List<ChurnData> _generateChurnData() {
    return [
      ChurnData('Low Risk', 60),
      ChurnData('Medium Risk', 25),
      ChurnData('High Risk', 15),
    ];
  }
}

class LTVData {
  final String segment;
  final double value;

  LTVData(this.segment, this.value);
}

class ChurnData {
  final String risk;
  final double percentage;

  ChurnData(this.risk, this.percentage);
}
