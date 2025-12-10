// lib/src/widgets/reports/financial_report_section.dart
import 'package:andalus_smart_pos/src/utils/chart_formatters.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class FinancialReportSection extends StatelessWidget {
  final FinancialReportData financialData;

  const FinancialReportSection({super.key, required this.financialData});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FinancialKPICards(financialData: financialData),
        const SizedBox(height: 16),
        ProfitMarginTrendChart(financialData: financialData),
        const SizedBox(height: 16),
        CashFlowAnalysisChart(financialData: financialData),
      ],
    );
  }
}

class FinancialKPICards extends StatelessWidget {
  final FinancialReportData financialData;

  const FinancialKPICards({super.key, required this.financialData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial KPIs',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildKPICard(
                  theme,
                  'Total Revenue',
                  AppFormatters.formatCurrency(financialData.totalRevenue),
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildKPICard(
                  theme,
                  'Net Revenue',
                  AppFormatters.formatCurrency(financialData.netRevenue),
                  Icons.account_balance,
                  Colors.blue,
                ),
                _buildKPICard(
                  theme,
                  'Profit Margin',
                  '${financialData.profitMargin.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
                _buildKPICard(
                  theme,
                  'Total Tax',
                  AppFormatters.formatCurrency(financialData.totalTax),
                  Icons.receipt,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(
      ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfitMarginTrendChart extends StatelessWidget {
  final FinancialReportData financialData;

  const ProfitMarginTrendChart({super.key, required this.financialData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profit Margin Trend',
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
                  numberFormat:
                      NumberFormat.decimalPercentPattern(decimalDigits: 1),
                ),
                series: <CartesianSeries<ProfitData, String>>[
                  LineSeries<ProfitData, String>(
                    dataSource: _generateSampleProfitData(),
                    xValueMapper: (data, _) => data.period,
                    yValueMapper: (data, _) => data.margin,
                    markerSettings: const MarkerSettings(isVisible: true),
                    animationDuration: 1000,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ProfitData> _generateSampleProfitData() {
    return [
      ProfitData('Jan', 22.5),
      ProfitData('Feb', 24.1),
      ProfitData('Mar', 23.8),
      ProfitData('Apr', 25.2),
      ProfitData('May', 26.0),
      ProfitData('Jun', 25.5),
    ];
  }
}

class CashFlowAnalysisChart extends StatelessWidget {
  final FinancialReportData financialData;

  const CashFlowAnalysisChart({super.key, required this.financialData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Flow Analysis',
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
                  numberFormat: ChartFormatters.currencyFormat,
                ),
                series: <CartesianSeries<CashFlowData, String>>[
                  ColumnSeries<CashFlowData, String>(
                    dataSource: _generateSampleCashFlowData(),
                    xValueMapper: (data, _) => data.period,
                    yValueMapper: (data, _) => data.amount,
                    animationDuration: 1000,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CashFlowData> _generateSampleCashFlowData() {
    return [
      CashFlowData('Jan', 150000),
      CashFlowData('Feb', 165000),
      CashFlowData('Mar', 142000),
      CashFlowData('Apr', 178000),
      CashFlowData('May', 195000),
      CashFlowData('Jun', 210000),
    ];
  }
}

class ProfitData {
  final String period;
  final double margin;

  ProfitData(this.period, this.margin);
}

class CashFlowData {
  final String period;
  final double amount;

  CashFlowData(this.period, this.amount);
}
