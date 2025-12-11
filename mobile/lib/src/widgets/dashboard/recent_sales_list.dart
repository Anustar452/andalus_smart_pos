// mobile/lib/src/widgets/dashboard/recent_sales_list.dart
// A recent sales list widget displaying the latest sales transactions on the dashboard.
import 'package:flutter/material.dart';
import 'package:andalus_smart_pos/src/data/models/sale.dart';
import 'package:andalus_smart_pos/src/utils/date_utils.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';

class RecentSalesList extends StatelessWidget {
  final List<Sale> sales;
  final AppLocalizations localizations;

  const RecentSalesList({
    super.key,
    required this.sales,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.translate('recentSales'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    localizations.translate('today'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (sales.isEmpty)
              _buildEmptyState(context)
            else
              Column(
                children: sales
                    .take(5)
                    .map((sale) => _buildSaleItem(context, sale))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleItem(BuildContext context, Sale sale) {
    final paymentColor = _getPaymentMethodColor(sale.paymentMethod);
    final idString = sale.id?.toString();
    final displayId = idString == null
        ? 'N/A' // Handle null case
        : (idString.length <= 6
            ? idString // If 6 chars or less, show the whole string
            : idString.substring(idString.length - 6));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: paymentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPaymentMethodIcon(sale.paymentMethod),
              color: paymentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   '${localizations.translate('sale')} #${sale.id?.substring(sale.id!.length - 6) ?? 'N/A'}',
                //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                //         fontWeight: FontWeight.w600,
                //       ),
                // ),
                Text(
                  '${localizations.translate('sale')} #$displayId',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppDateUtils.formatTime(sale.createdAt)} • ${_formatPaymentMethod(sale.paymentMethod, localizations)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sale.formattedTotal,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              Text(
                AppDateUtils.formatDate(sale.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.receipt_long_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          localizations.translate('noSalesToday'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.translate('completeFirstSale'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return const Color(0xFF10B981);
      case 'telebirr':
        return const Color(0xFF3B82F6);
      case 'card':
        return const Color(0xFF8B5CF6);
      case 'credit':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'telebirr':
        return Icons.qr_code_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'credit':
        return Icons.credit_score_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String _formatPaymentMethod(String method, AppLocalizations localizations) {
    switch (method.toLowerCase()) {
      case 'cash':
        return localizations.translate('cash');
      case 'telebirr':
        return localizations.translate('telebirr');
      case 'card':
        return localizations.translate('card');
      case 'credit':
        return localizations.translate('credit');
      default:
        return method;
    }
  }
}
