// lib/src/widgets/reports/customer_report_section.dart
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:andalus_smart_pos/src/utils/chart_formatters.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class CustomerReportSection extends StatelessWidget {
  final CustomersReportData customersData;
  final SubscriptionPlan plan;

  const CustomerReportSection({
    super.key,
    required this.customersData,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCustomersOverview(localizations, theme),
        const SizedBox(height: 16),
        _buildTopCustomersChart(localizations, theme),
        const SizedBox(height: 16),
        _buildOutstandingBalanceChart(localizations, theme),
        if (plan.id == 'enterprise') ...[
          const SizedBox(height: 16),
          _buildAdvancedCustomerAnalytics(localizations, theme),
        ],
      ],
    );
  }

  Widget _buildCustomersOverview(
      AppLocalizations localizations, ThemeData theme) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.customersOverview,
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
                _buildMetricCard(
                  theme,
                  // localizations.totalCustomers,
                  localizations.translate('total_customers'),
                  customersData.totalCustomers.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildMetricCard(
                  theme,
                  localizations.customersWithBalance,
                  customersData.customersWithBalance.toString(),
                  Icons.credit_card,
                  Colors.orange,
                ),
                _buildMetricCard(
                  theme,
                  localizations.overdue,
                  customersData.overdueCustomers.toString(),
                  Icons.warning,
                  Colors.red,
                ),
                _buildMetricCard(
                  theme,
                  localizations.outstandingCredit,
                  AppFormatters.formatCurrency(customersData.totalOutstanding),
                  Icons.money_off,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
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

  Widget _buildTopCustomersChart(
      AppLocalizations localizations, ThemeData theme) {
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
              height: 300,
              child: customersData.topCustomers.isNotEmpty
                  ? SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelRotation: -45,
                        majorGridLines: const MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        numberFormat: ChartFormatters.currencyFormat,
                      ),
                      series: <CartesianSeries<TopCustomer, String>>[
                        BarSeries<TopCustomer, String>(
                          dataSource:
                              customersData.topCustomers.take(8).toList(),
                          xValueMapper: (customer, _) => customer.name,
                          yValueMapper: (customer, _) => customer.totalSpent,
                          color: theme.colorScheme.secondary,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                        )
                      ],
                    )
                  : Center(
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

  Widget _buildOutstandingBalanceChart(
      AppLocalizations localizations, ThemeData theme) {
    // Simplified implementation - you can enhance this with real data
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
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'Advanced customer analytics available in Enterprise plan',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedCustomerAnalytics(
      AppLocalizations localizations, ThemeData theme) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Customer Analytics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Add enterprise-level customer analytics here
            Text(
              'Customer Lifetime Value, Churn Analysis, Segmentation',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
