// mobile/lib/src/providers/onboarding_provider.dart
// Provider for managing the onboarding and registration process.
import 'dart:async';

import 'package:andalus_smart_pos/src/providers/auth_provider.dart';
import 'package:andalus_smart_pos/src/providers/providers.dart'
    hide authServiceProvider, otpRepositoryProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/shop_registration.dart';
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:andalus_smart_pos/src/service/registration_service.dart';
import 'package:andalus_smart_pos/src/service/auth_service.dart';

class OnboardingState {
  final int currentStep;
  final ShopRegistration? shop;
  final OwnerRegistration? owner;
  final SubscriptionPlan? selectedPlan;
  final BillingCycle? billingCycle;
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final bool isVerifyingOTP;
  final String? registeredPhone;
  final String? tempBusinessId;
  final String? tempUserId;
  final int otpResendCooldown;

  const OnboardingState({
    this.currentStep = 0,
    this.shop,
    this.owner,
    this.selectedPlan,
    this.billingCycle,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.isVerifyingOTP = false,
    this.registeredPhone,
    this.tempBusinessId,
    this.tempUserId,
    this.otpResendCooldown = 0,
  });

  OnboardingState copyWith({
    int? currentStep,
    ShopRegistration? shop,
    OwnerRegistration? owner,
    SubscriptionPlan? selectedPlan,
    BillingCycle? billingCycle,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    bool? isVerifyingOTP,
    String? registeredPhone,
    String? tempBusinessId,
    String? tempUserId,
    int? otpResendCooldown,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      shop: shop ?? this.shop,
      owner: owner ?? this.owner,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      billingCycle: billingCycle ?? this.billingCycle,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      isVerifyingOTP: isVerifyingOTP ?? this.isVerifyingOTP,
      registeredPhone: registeredPhone ?? this.registeredPhone,
      tempBusinessId: tempBusinessId ?? this.tempBusinessId,
      tempUserId: tempUserId ?? this.tempUserId,
      otpResendCooldown: otpResendCooldown ?? this.otpResendCooldown,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;
  final RegistrationService _registrationService;
  final AuthService _authService;

  OnboardingNotifier(this._ref)
      : _registrationService = _ref.read(registrationServiceProvider),
        _authService = _ref.read(authServiceProvider),
        super(const OnboardingState());

  void updateShopInfo(ShopRegistration shop) {
    state = state.copyWith(shop: shop);
  }

  void updateOwnerInfo(OwnerRegistration owner) {
    state = state.copyWith(owner: owner);
  }

  void selectPlan(SubscriptionPlan plan, BillingCycle billingCycle) {
    state = state.copyWith(selectedPlan: plan, billingCycle: billingCycle);
  }

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1, error: null);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, error: null);
    }
  }

  Future<bool> _verifyOTP(String phone, String code) async {
    try {
      // Use your existing OTP verification logic
      if (code == '123456') return true; // Demo code

      final otp = await _ref
          .read(otpRepositoryProvider)
          .getValidOTP(phone, code, 'registration');
      if (otp != null) {
        await _ref.read(otpRepositoryProvider).markOTPAsUsed(otp.id);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendRegistrationOTP(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Use the same type 'registration' for both sending and verifying
      await _authService.sendRegistrationOTP(phone);
      _startResendCooldown();
      state = state.copyWith(
        isLoading: false,
        registeredPhone: phone,
      );

      print('📱 Registration OTP sent to: $phone');
    } catch (e) {
      print('❌ Failed to send registration OTP: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send OTP: ${e.toString()}',
      );
    }
  }

  void _startResendCooldown() {
    const cooldownDuration = 60;
    state = state.copyWith(otpResendCooldown: cooldownDuration);

    // 1. Declare the variable first (nullable)
    StreamSubscription? timer;

    // 2. Assign the subscription
    timer = Stream.periodic(const Duration(seconds: 1), (i) {
      final remaining = cooldownDuration - i - 1;

      if (remaining >= 0) {
        state = state.copyWith(otpResendCooldown: remaining);
      } else {
        state = state.copyWith(otpResendCooldown: 0);
        // 3. Now you can refer to 'timer' safely
        timer?.cancel();
      }
    }).listen((_) {});
  }

  Future<bool> verifyRegistrationOTP(String code) async {
    print('🔄 verifyRegistrationOTP called with code: $code');

    if (state.registeredPhone == null) {
      state = state.copyWith(error: 'Phone number not set');
      return false;
    }

    // Check if we're already verifying
    if (state.isVerifyingOTP) {
      print('⚠️ Already verifying OTP, ignoring duplicate call');
      return false;
    }

    state = state.copyWith(isVerifyingOTP: true, error: null);

    try {
      print('🔐 Verifying OTP for: ${state.registeredPhone}');
      print('🔑 OTP Code entered: $code');

      final otp = await _ref
          .read(otpRepositoryProvider)
          .getValidOTP(state.registeredPhone!, code, 'registration');

      if (otp == null) {
        print('❌ No valid OTP found for ${state.registeredPhone}');
        state = state.copyWith(
          isVerifyingOTP: false,
          error: 'Invalid or expired OTP code',
        );
        return false;
      }

      print('✅ Valid OTP found, marking as used...');
      await _ref.read(otpRepositoryProvider).markOTPAsUsed(otp.id);

      // Create temporary registration after OTP verification
      if (state.shop != null &&
          state.owner != null &&
          state.selectedPlan != null &&
          state.billingCycle != null) {
        print('🏪 Creating temporary registration...');
        final result = await _registrationService.createTemporaryRegistration(
          shop: state.shop!,
          owner: state.owner!,
          plan: state.selectedPlan!,
          billingCycle: state.billingCycle!,
        );

        if (result.success) {
          print('✅ Temporary registration created successfully');

          // Update state first
          state = state.copyWith(
            isVerifyingOTP: false,
            tempBusinessId: result.businessId,
            tempUserId: result.userId,
            error: null,
          );

          print('🚀 Moving to next step...');
          // Then move to next step
          nextStep();

          return true;
        } else {
          print('❌ Temporary registration failed: ${result.error}');
          state = state.copyWith(
            isVerifyingOTP: false,
            error: result.error ?? 'Registration failed',
          );
          return false;
        }
      } else {
        print('❌ Incomplete registration data');
        state = state.copyWith(
          isVerifyingOTP: false,
          error: 'Registration data incomplete',
        );
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ OTP verification error: $e');
      print('📋 Stack trace: $stackTrace');
      state = state.copyWith(
        isVerifyingOTP: false,
        error: 'OTP verification failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> processPayment(
      String paymentMethod, Map<String, dynamic> paymentDetails) async {
    if (state.tempBusinessId == null || state.tempUserId == null) {
      state = state.copyWith(error: 'Registration data missing');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Generate payment reference
      final paymentReference = 'pay_${DateTime.now().millisecondsSinceEpoch}';
      final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';

      // Activate account after successful payment
      final result = await _registrationService.activateAccountAfterPayment(
        businessId: state.tempBusinessId!,
        userId: state.tempUserId!,
        paymentReference: paymentReference,
        transactionId: transactionId,
      );

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Payment processing failed: ${e.toString()}',
      );
      return false;
    }
  }

  void reset() {
    state = const OnboardingState();
  }

  bool get canResendOTP => state.otpResendCooldown == 0;
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});
