// lib/src/widgets/reports/top_customers_chart.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../localization/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class TopCustomersChart extends StatelessWidget {
  final List<TopCustomer> customers;

  const TopCustomersChart({super.key, required this.customers});

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
              localizations.topCustomers,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: customers.isNotEmpty
                  ? SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelRotation: -45,
                        majorGridLines: const MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        numberFormat: NumberFormat.currency(symbol: 'ETB '),
                        majorGridLines: const MajorGridLines(width: 0.5),
                      ),
                      series: <CartesianSeries<TopCustomer, String>>[
                        BarSeries<TopCustomer, String>(
                          dataSource: customers.take(10).toList(),
                          xValueMapper: (customer, _) =>
                              _truncateName(customer.name),
                          yValueMapper: (customer, _) => customer.totalSpent,
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
                    )
                  : Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Text(
                        'No customer data available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateName(String name) {
    return name.length > 15 ? '${name.substring(0, 15)}...' : name;
  }
}
