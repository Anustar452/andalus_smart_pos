import 'package:flutter/material.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';

class QuickActionsWidget extends StatelessWidget {
  final AppLocalizations localizations;

  const QuickActionsWidget({
    super.key,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Icons.point_of_sale_rounded,
        'label': localizations.translate('newSale'),
        'route': '/pos',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.inventory_2_rounded,
        'label': localizations.translate('addProduct'),
        'route': '/products',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.people_rounded,
        'label': localizations.translate('addCustomer'),
        'route': '/customers',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': localizations.translate('reports'),
        'route': '/reports',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('quickActions'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions
                  .map((action) => _buildActionChip(context, action))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, Map<String, dynamic> action) {
    return ActionChip(
      avatar: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: action['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          action['icon'],
          size: 16,
          color: action['color'],
        ),
      ),
      label: Text(
        action['label'],
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: action['color'],
        ),
      ),
      onPressed: () => Navigator.pushNamed(context, action['route']),
      backgroundColor: action['color'].withOpacity(0.05),
      side: BorderSide(
        color: action['color'].withOpacity(0.2),
      ),
    );
  }
}
