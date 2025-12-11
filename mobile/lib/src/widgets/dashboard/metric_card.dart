// mobile/lib/src/widgets/dashboard/metric_card.dart
// A reusable metric card widget for displaying key performance indicators on the dashboard.
import 'package:flutter/material.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;
  final AppLocalizations localizations;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isWarning
                ? const Color(0xFFEF4444)
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isWarning
                      ? const Color(0xFFEF4444)
                      : Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
