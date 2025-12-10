// lib/src/widgets/reports/outstanding_balance_chart.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class OutstandingBalanceChart extends StatelessWidget {
  final CustomersReportData customersData;

  const OutstandingBalanceChart({super.key, required this.customersData});

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
              'Outstanding Balance Analysis',
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
                  numberFormat: NumberFormat.currency(symbol: 'ETB '),
                ),
                series: <CartesianSeries<BalanceData, String>>[
                  ColumnSeries<BalanceData, String>(
                    dataSource: _generateBalanceData(),
                    xValueMapper: (data, _) => data.range,
                    yValueMapper: (data, _) => data.amount,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BalanceData> _generateBalanceData() {
    return [
      BalanceData('0-1,000', 45000),
      BalanceData('1,000-5,000', 125000),
      BalanceData('5,000-10,000', 85000),
      BalanceData('10,000+', 250000),
    ];
  }
}

class BalanceData {
  final String range;
  final double amount;

  BalanceData(this.range, this.amount);
}
