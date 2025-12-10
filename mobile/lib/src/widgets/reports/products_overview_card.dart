// lib/src/widgets/reports/products_overview_card.dart
import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class ProductsOverviewCard extends StatelessWidget {
  final ProductsReportData productsData;

  const ProductsOverviewCard({super.key, required this.productsData});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.productsOverview,
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
                  localizations.totalProducts,
                  AppFormatters.formatNumber(productsData.totalProducts),
                  Icons.inventory_2,
                  Colors.blue,
                ),
                _buildMetricCard(
                  theme,
                  localizations.lowStock,
                  AppFormatters.formatNumber(productsData.lowStockCount),
                  Icons.warning,
                  Colors.orange,
                ),
                _buildMetricCard(
                  theme,
                  localizations.outOfStock,
                  AppFormatters.formatNumber(productsData.outOfStockCount),
                  Icons.error,
                  Colors.red,
                ),
                _buildMetricCard(
                  theme,
                  'Stock Value',
                  AppFormatters.formatCurrency(productsData.stockValue),
                  Icons.warehouse,
                  Colors.green,
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
}
