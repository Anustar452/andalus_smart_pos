// lib/src/widgets/reports/subscription_info_card.dart
// Subscription info card widget displaying current subscription plan details.
import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../data/models/subscription.dart';
import '../common/custom_card.dart';

class SubscriptionInfoCard extends StatelessWidget {
  final SubscriptionPlan plan;

  const SubscriptionInfoCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final planColor = _getPlanColor(theme);
    final planDescription = _getPlanDescription(localizations);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.workspace_premium, color: planColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.name} ${localizations.plan}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: planColor,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      planDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (plan.id == 'basic') ...[
                      const SizedBox(height: 4),
                      Text(
                        localizations.upgradeForAdvancedReports,
                        style: TextStyle(
                          fontSize: 12,
                          color: planColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (plan.id == 'basic')
                TextButton(
                  onPressed: () => _showUpgradeDialog(context),
                  child: Text(localizations.upgrade),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPlanColor(ThemeData theme) {
    switch (plan.id) {
      case 'basic':
        return theme.colorScheme.primary;
      case 'professional':
        return Colors.green;
      case 'enterprise':
        return Colors.purple;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _getPlanDescription(AppLocalizations localizations) {
    switch (plan.id) {
      case 'basic':
        return localizations.basicReportsDescription;
      case 'professional':
        return localizations.professionalReportsDescription;
      case 'enterprise':
        return localizations.enterpriseReportsDescription;
      default:
        return localizations.basicReportsDescription;
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.upgradeYourPlan),
        content: Text(localizations.upgradeForAdvancedAnalytics),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription plans screen
            },
            child: Text(localizations.viewPlans),
          ),
        ],
      ),
    );
  }
}
