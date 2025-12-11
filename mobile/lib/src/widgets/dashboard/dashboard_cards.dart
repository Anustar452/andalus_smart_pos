// widgets/dashboard/dashboard_cards.dart
// Dashboard cards displaying key metrics like sales, products, customers, and revenue.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isWarning;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 130, // Reduced fixed height
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with icon and arrow - Fixed height
              SizedBox(
                height: 32, // Fixed height for top row
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6), // Smaller padding
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 18), // Smaller icon
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color.withOpacity(0.6),
                      size: 12, // Smaller arrow
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Content area with strict height constraints
              SizedBox(
                height: 60, // Fixed height for content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Main value - with strict constraints
                    SizedBox(
                      height: 24, // Fixed height for main value
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isWarning
                                    ? const Color(0xFFEF4444)
                                    : Theme.of(context).colorScheme.onSurface,
                                fontSize: 16, // Smaller font
                              ),
                          maxLines: 1,
                        ),
                      ),
                    ),

                    // Subtitle - with strict constraints
                    SizedBox(
                      height: 16, // Fixed height for subtitle
                      child: Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w500,
                              fontSize: 11, // Smaller font
                              height: 1.2, // Tighter line height
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Title - with strict constraints
                    SizedBox(
                      height: 16, // Fixed height for title
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w600,
                              fontSize: 12, // Smaller font
                              height: 1.2, // Tighter line height
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SalesCard extends ConsumerWidget {
  final double todaySales;
  final int itemsSold;
  final VoidCallback onTap;

  const SalesCard({
    super.key,
    required this.todaySales,
    required this.itemsSold,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    return DashboardCard(
      title: localizations.translate('Sales'),
      value: AppFormatters.formatCurrency(todaySales),
      subtitle: '$itemsSold ${localizations.translate('items sold')}',
      icon: Icons.shopping_cart_rounded,
      color: const Color(0xFF10B981),
      onTap: onTap,
    );
  }
}

class ProductsCard extends ConsumerWidget {
  final int totalProducts;
  final int totalItems;
  final int totalCategories;
  final VoidCallback onTap;

  const ProductsCard({
    super.key,
    required this.totalProducts,
    required this.totalItems,
    required this.totalCategories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    // Use shorter text to prevent overflow
    final subtitle = '$totalItems items • $totalCategories cats';

    return DashboardCard(
      title: localizations.translate('Products'),
      value: totalProducts.toString(),
      subtitle: subtitle,
      icon: Icons.inventory_2_rounded,
      color: const Color(0xFF3B82F6),
      onTap: onTap,
    );
  }
}

class CustomersCard extends ConsumerWidget {
  final int totalCustomers;
  final int customersWithBalance;
  final VoidCallback onTap;

  const CustomersCard({
    super.key,
    required this.totalCustomers,
    required this.customersWithBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    // Use shorter text
    final subtitle = '$customersWithBalance with balance';

    return DashboardCard(
      title: localizations.translate('Customers'),
      value: totalCustomers.toString(),
      subtitle: subtitle,
      icon: Icons.people_alt_rounded,
      color: const Color(0xFF8B5CF6),
      onTap: onTap,
    );
  }
}

class RevenueCard extends ConsumerWidget {
  final double totalRevenue;
  final double outstandingCredit;
  final VoidCallback onTap;

  const RevenueCard({
    super.key,
    required this.totalRevenue,
    required this.outstandingCredit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    // Use compact format for large numbers
    final formattedRevenue = totalRevenue > 10000
        ? AppFormatters.formatCompactCurrency(totalRevenue)
        : AppFormatters.formatCurrency(totalRevenue);

    final formattedCredit = outstandingCredit > 10000
        ? AppFormatters.formatCompactCurrency(outstandingCredit)
        : AppFormatters.formatCurrency(outstandingCredit);

    // Use shorter text
    final subtitle = 'Out: $formattedCredit';

    return DashboardCard(
      title: localizations.translate('Revenue'),
      value: formattedRevenue,
      subtitle: subtitle,
      icon: Icons.attach_money_rounded,
      color: outstandingCredit > 0
          ? const Color(0xFFF59E0B)
          : const Color(0xFF10B981),
      onTap: onTap,
      isWarning: outstandingCredit > 0,
    );
  }
}
