// src/ui/screens/onboarding/payment_screen.dart
// Screen for handling payment during the onboarding process.
import 'package:andalus_smart_pos/src/ui/screens/main_navigation.dart';
import 'package:andalus_smart_pos/src/widgets/common/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/providers/onboarding_provider.dart';
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:andalus_smart_pos/src/ui/screens/dashboard_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String? _selectedPaymentMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'telebirr',
      'name': 'Telebirr',
      'icon': Icons.phone_android_rounded,
      'color': Colors.blue,
      'description': 'Instant payment via Telebirr mobile money',
    },
    {
      'id': 'cbe_birr',
      'name': 'CBE Birr',
      'icon': Icons.account_balance_rounded,
      'color': Colors.green,
      'description': 'Mobile banking with Commercial Bank of Ethiopia',
    },
    {
      'id': 'chapa',
      'name': 'Chapa',
      'icon': Icons.payment_rounded,
      'color': Colors.orange,
      'description': 'Secure online payment gateway',
    },
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Colors.purple,
      'description': 'Direct bank transfer to our account',
    },
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a payment method'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(onboardingProvider.notifier).processPayment(
      _selectedPaymentMethod!,
      {
        'method': _selectedPaymentMethod,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );
  }

  void _navigateToMain() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('payment')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(onboardingProvider.notifier).previousStep(),
        ),
      ),
      body: Column(
        children: [
          // Fixed Header Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(4, loc),
                const SizedBox(height: 32),
                Text(
                  loc.translate('completePayment'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('choosePaymentMethod'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content Section
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Order Summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildOrderSummary(state, theme, loc),
                  ),
                ),

                // Payment Methods Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      children: [
                        Text(
                          loc.translate('paymentMethods'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _paymentMethods.length.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Payment Methods List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final method = _paymentMethods[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          0,
                          24,
                          index == _paymentMethods.length - 1 ? 24 : 12,
                        ),
                        child: _buildPaymentMethodCard(method, theme, loc),
                      );
                    },
                    childCount: _paymentMethods.length,
                  ),
                ),

                // Demo Notice
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: _buildDemoNotice(theme),
                  ),
                ),
              ],
            ),
          ),

          // Fixed Footer with Process Payment Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                AppButton.primary(
                  onPressed: state.isLoading ? null : _processPayment,
                  isLoading: state.isLoading,
                  child: Text(
                    loc.translate('processPayment'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No payment required during 14-day free trial',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
      Map<String, dynamic> method, ThemeData theme, AppLocalizations loc) {
    final isSelected = _selectedPaymentMethod == method['id'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method['id'];
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? method['color']
                        : method['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    method['icon'],
                    color: isSelected ? Colors.white : method['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method['description'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoNotice(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo Mode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Select any payment method to continue. No actual payment will be processed during the 14-day free trial.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
      OnboardingState state, ThemeData theme, AppLocalizations loc) {
    final plan = state.selectedPlan;
    final billingCycle = state.billingCycle;

    if (plan == null || billingCycle == null) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.translate('orderSummary'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Plan Details
            _buildSummaryRow('Subscription Plan', plan.name, theme),
            _buildSummaryRow(
              'Billing Cycle',
              billingCycle == BillingCycle.monthly ? 'Monthly' : 'Yearly',
              theme,
            ),
            const SizedBox(height: 8),

            // Divider
            Divider(
              color: theme.colorScheme.outline.withOpacity(0.1),
              height: 1,
            ),
            const SizedBox(height: 16),

            // Total Amount
            _buildSummaryRow(
              'Total Amount',
              plan.getFormattedPrice(billingCycle),
              theme,
              isTotal: true,
            ),
            const SizedBox(height: 16),

            // Free Trial Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.celebration_rounded,
                    size: 20,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '14-Day Free Trial',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No payment required now. Your trial starts immediately after registration.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 40,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Welcome to Andalus POS! 🎉',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                // textAlign: TextAlign.center,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Your account has been successfully created and your 14-day free trial has started.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Features List
            _buildFeatureItem('14-day full access to all features'),
            _buildFeatureItem('No credit card required'),
            _buildFeatureItem('Setup your products and start selling'),
            const SizedBox(height: 32),

            // Get Started Button
            AppButton.primary(
              onPressed: _navigateToMain,
              child: Text(
                'Get Started',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep, AppLocalizations loc) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStep(1, '🏪', loc.translate('shop'), currentStep >= 0),
            _buildStep(2, '👤', loc.translate('owner'), currentStep >= 1),
            _buildStep(3, '📦', loc.translate('plan'), currentStep >= 2),
            _buildStep(4, '🔐', loc.translate('verify'), currentStep >= 3),
            _buildStep(5, '💳', loc.translate('payment'), currentStep >= 4),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${currentStep + 1}/5 ${loc.translate('steps')}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildStep(int stepNumber, String emoji, String label, bool isActive) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceVariant,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
