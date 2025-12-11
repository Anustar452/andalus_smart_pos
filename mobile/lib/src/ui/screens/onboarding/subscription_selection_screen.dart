// src/ui/screens/onboarding/subscription_selection_screen.dart
// Screen for selecting a subscription plan during the onboarding process.
import 'package:andalus_smart_pos/src/widgets/common/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/providers/onboarding_provider.dart';
import 'package:andalus_smart_pos/src/data/models/subscription.dart';

class SubscriptionSelectionScreen extends ConsumerStatefulWidget {
  const SubscriptionSelectionScreen({super.key});

  @override
  ConsumerState<SubscriptionSelectionScreen> createState() =>
      _SubscriptionSelectionScreenState();
}

class _SubscriptionSelectionScreenState
    extends ConsumerState<SubscriptionSelectionScreen> {
  bool _isYearlyBilling = false;
  SubscriptionPlan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    // Set Professional as default selected plan
    _selectedPlan = SubscriptionPlan.professional;
  }

  void _selectPlan(SubscriptionPlan plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  void _toggleBillingCycle() {
    setState(() {
      _isYearlyBilling = !_isYearlyBilling;
    });
  }

  void _proceedToNextStep() {
    if (_selectedPlan != null) {
      ref.read(onboardingProvider.notifier).selectPlan(
            _selectedPlan!,
            _isYearlyBilling ? BillingCycle.yearly : BillingCycle.monthly,
          );
      ref.read(onboardingProvider.notifier).nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('subscriptionPlan')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(onboardingProvider.notifier).previousStep(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProgressIndicator(2, loc),
            const SizedBox(height: 32),
            Text(
              loc.translate('chooseYourPlan'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('startWithFreeTrial'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Billing Cycle Toggle
            _buildBillingCycleToggle(theme, loc),
            const SizedBox(height: 32),

            // Subscription Plans
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPlanCard(SubscriptionPlan.basic, theme, loc),
                    const SizedBox(height: 16),
                    _buildPlanCard(SubscriptionPlan.professional, theme, loc),
                    const SizedBox(height: 16),
                    _buildPlanCard(SubscriptionPlan.premium, theme, loc),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            AppButton.primary(
              onPressed: _selectedPlan != null ? _proceedToNextStep : null,
              child: Text(loc.translate('continue')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingCycleToggle(ThemeData theme, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearlyBilling = false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: !_isYearlyBilling
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    loc.translate('monthly'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: !_isYearlyBilling
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearlyBilling = true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _isYearlyBilling
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        loc.translate('yearly'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _isYearlyBilling
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        loc.translate('save20Percent'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _isYearlyBilling
                              ? theme.colorScheme.onPrimary.withOpacity(0.8)
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      SubscriptionPlan plan, ThemeData theme, AppLocalizations loc) {
    final isSelected = _selectedPlan?.id == plan.id;
    final isRecommended = plan.id == 'professional';

    return Card(
      margin: EdgeInsets.zero,
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
        onTap: () => _selectPlan(plan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isRecommended) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        loc.translate('recommended'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                plan.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),

              // Price
              Text(
                _isYearlyBilling
                    ? plan.getFormattedPrice(BillingCycle.yearly)
                    : plan.getFormattedPrice(BillingCycle.monthly),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (_isYearlyBilling) ...[
                const SizedBox(height: 4),
                Text(
                  plan.savingsInfo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Features
              ...plan.features.take(4).map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),

              // Selection indicator
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
                child: Center(
                  child: Text(
                    isSelected
                        ? loc.translate('selected')
                        : loc.translate('selectPlan'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
        ),
      ],
    );
  }
}
