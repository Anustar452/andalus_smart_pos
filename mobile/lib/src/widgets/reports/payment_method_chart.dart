// lib/src/widgets/reports/payment_method_chart.dart
// Payment method chart widget displaying sales distribution by payment methods.
// This includes a doughnut chart visualizing the breakdown of sales by different payment types.
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../common/custom_card.dart';

class PaymentMethodChart extends StatelessWidget {
  final Map<String, double> paymentMethods;

  const PaymentMethodChart({super.key, required this.paymentMethods});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final chartData = paymentMethods.entries
        .map((entry) => _ChartData(
            _getPaymentMethodName(entry.key, localizations), entry.value))
        .toList();

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.salesByPaymentMethod,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                palette: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                  theme.colorScheme.tertiary,
                  Colors.amber,
                  Colors.teal,
                ],
                series: <CircularSeries>[
                  DoughnutSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: theme.textTheme.bodySmall,
                      labelIntersectAction: LabelIntersectAction.shift,
                    ),
                    animationDuration: 1000,
                  )
                ],
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: theme.textTheme.bodyMedium,
                ),
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

  String _getPaymentMethodName(String method, AppLocalizations localizations) {
    switch (method.toLowerCase()) {
      case 'cash':
        return localizations.cash;
      case 'telebirr':
        return localizations.telebirr;
      case 'card':
        return localizations.card;
      case 'credit':
        return localizations.credit;
      case 'bank_transfer':
        return localizations.bankTransfer;
      default:
        return method;
    }
  }
}

class _ChartData {
  final String x;
  final double y;

  _ChartData(this.x, this.y);
}
