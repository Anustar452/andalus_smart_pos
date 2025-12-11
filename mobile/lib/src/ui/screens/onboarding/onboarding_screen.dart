// src/ui/screens/onboarding/onboarding_screen.dart
// Onboarding screen that manages the multi-step onboarding process.
import 'package:andalus_smart_pos/src/ui/screens/onboarding/onboarding_otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/providers/onboarding_provider.dart';
import 'package:andalus_smart_pos/src/ui/screens/onboarding/shop_registration_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/onboarding/owner_registration_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/onboarding/subscription_selection_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/onboarding/otp_verification_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/onboarding/payment_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _buildStepContent(state.currentStep),
    );
  }

// In onboarding_screen.dart - update the _buildStepContent method
  Widget _buildStepContent(int currentStep) {
    switch (currentStep) {
      case 0:
        return const ShopRegistrationScreen();
      case 1:
        return const OwnerRegistrationScreen();
      case 2:
        return const SubscriptionSelectionScreen();
      case 3:
        return const OnboardingOTPVerificationScreen(); // Use the new dedicated screen
      case 4:
        return const PaymentScreen();
      default:
        return const ShopRegistrationScreen();
    }
  }
}
