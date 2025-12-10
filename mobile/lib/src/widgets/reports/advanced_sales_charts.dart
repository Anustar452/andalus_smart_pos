// lib/src/widgets/reports/advanced_sales_charts.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class AdvancedSalesCharts extends StatelessWidget {
  final SalesReportData salesData;

  const AdvancedSalesCharts({super.key, required this.salesData});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Sales Velocity Chart
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales Velocity',
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
                      title: AxisTitle(text: 'Sales per Day'),
                    ),
                    series: <CartesianSeries<SalesVelocityData, String>>[
                      LineSeries<SalesVelocityData, String>(
                        dataSource: _generateSalesVelocityData(),
                        xValueMapper: (data, _) => data.period,
                        yValueMapper: (data, _) => data.velocity,
                        markerSettings: const MarkerSettings(isVisible: true),
                        animationDuration: 1000,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Customer Retention Chart
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Retention',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      DoughnutSeries<RetentionData, String>(
                        dataSource: _generateRetentionData(),
                        xValueMapper: (data, _) => data.category,
                        yValueMapper: (data, _) => data.value,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      )
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

  List<SalesVelocityData> _generateSalesVelocityData() {
    return [
      SalesVelocityData('Week 1', 15.2),
      SalesVelocityData('Week 2', 18.5),
      SalesVelocityData('Week 3', 16.8),
      SalesVelocityData('Week 4', 22.1),
    ];
  }

  List<RetentionData> _generateRetentionData() {
    return [
      RetentionData('Repeat Customers', 65),
      RetentionData('New Customers', 25),
      RetentionData('Lost Customers', 10),
    ];
  }
}

class SalesVelocityData {
  final String period;
  final double velocity;

  SalesVelocityData(this.period, this.velocity);
}

class RetentionData {
  final String category;
  final double value;

  RetentionData(this.category, this.value);
}
