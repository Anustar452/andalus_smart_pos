import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/service/registration_service.dart';
import 'package:andalus_smart_pos/src/data/models/registration.dart';
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';

final registrationServiceProvider = Provider<RegistrationService>((ref) {
  return RegistrationService(
    userRepository: ref.read(userRepositoryProvider),
    subscriptionRepository: ref.read(subscriptionRepositoryProvider),
  );
});

class RegistrationState {
  final int currentStep;
  final BusinessRegistration? business;
  final UserRegistration? user;
  final SubscriptionPlan? selectedPlan;
  final BillingCycle? billingCycle;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const RegistrationState({
    this.currentStep = 0,
    this.business,
    this.user,
    this.selectedPlan,
    this.billingCycle,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  RegistrationState copyWith({
    int? currentStep,
    BusinessRegistration? business,
    UserRegistration? user,
    SubscriptionPlan? selectedPlan,
    BillingCycle? billingCycle,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      business: business ?? this.business,
      user: user ?? this.user,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      billingCycle: billingCycle ?? this.billingCycle,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final Ref _ref;

  RegistrationNotifier(this._ref) : super(const RegistrationState());

  void updateBusinessInfo(BusinessRegistration business) {
    state = state.copyWith(business: business);
  }

  void updateUserInfo(UserRegistration user) {
    state = state.copyWith(user: user);
  }

  void selectPlan(SubscriptionPlan plan, BillingCycle billingCycle) {
    state = state.copyWith(
      selectedPlan: plan,
      billingCycle: billingCycle,
    );
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1, error: null);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, error: null);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      state = state.copyWith(currentStep: step, error: null);
    }
  }

  Future<void> completeRegistration() async {
    if (state.business == null ||
        state.user == null ||
        state.selectedPlan == null ||
        state.billingCycle == null) {
      state = state.copyWith(error: 'Please complete all registration steps');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final registrationService = _ref.read(registrationServiceProvider);

      // Check if phone numbers are already registered
      final businessPhoneExists = await registrationService
          .checkBusinessPhoneExists(state.business!.phone);
      if (businessPhoneExists) {
        throw Exception('Business phone number is already registered');
      }

      final userPhoneExists =
          await registrationService.checkUserPhoneExists(state.user!.phone);
      if (userPhoneExists) {
        throw Exception('User phone number is already registered');
      }

      // Register business and user
      final result = await registrationService.registerBusiness(
        business: state.business!,
        user: state.user!,
        plan: state.selectedPlan!,
        billingCycle: state.billingCycle!,
      );

      if (!result.success) {
        throw Exception(result.error);
      }

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<PaymentResult> processPayment() async {
    if (state.business == null ||
        state.user == null ||
        state.selectedPlan == null ||
        state.billingCycle == null) {
      return PaymentResult.failure('Registration not completed');
    }

    try {
      final registrationService = _ref.read(registrationServiceProvider);

      // For demo, we'll process payment after registration
      // In real app, you might want to process payment before registration
      final result = await registrationService.processSubscriptionPayment(
        businessId:
            'business_${DateTime.now().millisecondsSinceEpoch}', // This would come from registration
        userId:
            'user_${DateTime.now().millisecondsSinceEpoch}', // This would come from registration
        plan: state.selectedPlan!,
        billingCycle: state.billingCycle!,
        paymentMethod: 'telebirr',
        paymentDetails: {},
      );

      return result;
    } catch (e) {
      return PaymentResult.failure(e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const RegistrationState();
  }
}

final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier(ref);
});
