// ui/screens/subscription_plans_screen.dart
// Screen for displaying and managing subscription plans.
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  SubscriptionPlan? _selectedPlan;
  BillingCycle _billingCycle = BillingCycle.monthly;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.telebirr;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('subscriptionPlans')),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(localizations, theme),
            const SizedBox(height: 24),
            _buildBillingCycleSelector(localizations, theme),
            const SizedBox(height: 24),
            ..._buildPlanCards(localizations, theme),
            const SizedBox(height: 32),
            if (_selectedPlan != null)
              _buildPaymentSection(localizations, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AppLocalizations localizations, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.primary.withOpacity(0.05),
            ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.workspace_premium,
              size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            localizations.translate('choosePerfectPlan'),
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('startWithFreeTrial'),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCycleSelector(
      AppLocalizations localizations, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBillingOption(
          BillingCycle.monthly,
          localizations.translate('monthly'),
          theme,
        ),
        const SizedBox(width: 16),
        _buildBillingOption(
          BillingCycle.yearly,
          localizations.translate('yearly'),
          theme,
        ),
      ],
    );
  }

  Widget _buildBillingOption(
      BillingCycle cycle, String label, ThemeData theme) {
    final isSelected = _billingCycle == cycle;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _billingCycle = cycle),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (cycle == BillingCycle.yearly) ...[
                const SizedBox(height: 4),
                Text(
                  // localizations.translate('performanceOverview')
                  'Save 20%',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPlanCards(
      AppLocalizations localizations, ThemeData theme) {
    return SubscriptionPlan.all
        .map((plan) => _buildPlanCard(plan, localizations, theme))
        .toList();
  }

  Widget _buildPlanCard(
      SubscriptionPlan plan, AppLocalizations localizations, ThemeData theme) {
    final isSelected = _selectedPlan == plan;
    final isPopular = plan.id == 'professional';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isSelected || isPopular)
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getPlanColor(plan, theme).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(plan.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getPlanColor(plan, theme),
                            )),
                        if (isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getPlanColor(plan, theme),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              localizations.translate('popular'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(plan.description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Text(
                      plan.getFormattedPrice(_billingCycle),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getPlanColor(plan, theme),
                      ),
                    ),
                    if (_billingCycle == BillingCycle.yearly) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.savingsInfo,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),

              // Features
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...plan.features.map((feature) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: _getPlanColor(plan, theme), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(feature,
                                      style: theme.textTheme.bodyMedium)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _selectedPlan = plan),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? _getPlanColor(plan, theme)
                              : Colors.transparent,
                          foregroundColor: isSelected
                              ? Colors.white
                              : _getPlanColor(plan, theme),
                          side: BorderSide(color: _getPlanColor(plan, theme)),
                        ),
                        child: Text(isSelected
                            ? localizations.translate('selected')
                            : localizations.translate('selectPlan')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(AppLocalizations localizations, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.translate('paymentMethod'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildPaymentMethodSelector(localizations, theme),
        const SizedBox(height: 24),
        _buildOrderSummary(localizations, theme),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(localizations.translate('subscribeNow')),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(
      AppLocalizations localizations, ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: PaymentMethod.values
          .map((method) =>
              _buildPaymentMethodOption(method, localizations, theme))
          .toList(),
    );
  }

  Widget _buildPaymentMethodOption(
      PaymentMethod method, AppLocalizations localizations, ThemeData theme) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getPaymentMethodIcon(method),
                color: _getPaymentMethodColor(method)),
            const SizedBox(width: 8),
            Text(_getPaymentMethodName(method, localizations)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(AppLocalizations localizations, ThemeData theme) {
    final price = _selectedPlan!.getPrice(_billingCycle);
    final tax = price * 0.15; // 15% tax
    final total = price + tax;

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.translate('orderSummary'),
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildOrderRow(localizations.translate('plan'),
                '${_selectedPlan!.name} (${_billingCycle.displayName})'),
            _buildOrderRow(localizations.translate('price'),
                AppFormatters.formatCurrency(price)),
            _buildOrderRow(localizations.translate('tax'),
                AppFormatters.formatCurrency(tax)),
            const Divider(),
            _buildOrderRow(localizations.translate('total'),
                AppFormatters.formatCurrency(total),
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPlan == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PaymentProcessingDialog(),
    );

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context); // Close loading dialog

      // Show success dialog
      _showPaymentSuccessDialog();
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showPaymentErrorDialog(e.toString());
    }
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content:
            const Text('Your subscription has been activated successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to reports screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showPaymentErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text('Error: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getPlanColor(SubscriptionPlan plan, ThemeData theme) {
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

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.telebirr:
        return Icons.phone_android;
      case PaymentMethod.bank:
        return Icons.account_balance;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.card:
        return Icons.credit_card;
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.telebirr:
        return Colors.green;
      case PaymentMethod.bank:
        return Colors.blue;
      case PaymentMethod.cash:
        return Colors.orange;
      case PaymentMethod.card:
        return Colors.purple;
    }
  }

  String _getPaymentMethodName(
      PaymentMethod method, AppLocalizations localizations) {
    switch (method) {
      case PaymentMethod.telebirr:
        return 'Telebirr';
      case PaymentMethod.bank:
        return localizations.translate('bankTransfer');
      case PaymentMethod.cash:
        return localizations.translate('cash');
      case PaymentMethod.card:
        return localizations.translate('card');
    }
  }
}

class PaymentProcessingDialog extends StatelessWidget {
  const PaymentProcessingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Processing Payment...'),
          ],
        ),
      ),
    );
  }
}

enum PaymentMethod { telebirr, bank, cash, card }
