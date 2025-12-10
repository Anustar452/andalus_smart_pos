// // src/providers/registration_provider.dart
// import 'dart:async';

// import 'package:andalus_smart_pos/src/providers/auth_provider.dart';
// import 'package:andalus_smart_pos/src/providers/providers.dart'
//     hide authServiceProvider;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:andalus_smart_pos/src/data/models/registration.dart';
// import 'package:andalus_smart_pos/src/data/models/subscription.dart';
// import 'package:andalus_smart_pos/src/data/models/user.dart';
// import 'package:andalus_smart_pos/src/service/registration_service.dart';
// import 'package:andalus_smart_pos/src/service/auth_service.dart';
// import 'package:crypto/crypto.dart';
// import 'dart:convert';

// class RegistrationState {
//   final int currentStep;
//   final BusinessRegistration? business;
//   final UserRegistration? user;
//   final SubscriptionPlan? selectedPlan;
//   final BillingCycle? billingCycle;
//   final bool isLoading;
//   final bool isSuccess;
//   final String? error;
//   final bool isVerifyingOTP;
//   final String? registeredPhone;
//   final String? businessId;
//   final String? userId;
//   final int otpResendCooldown;

//   const RegistrationState({
//     this.currentStep = 0,
//     this.business,
//     this.user,
//     this.selectedPlan,
//     this.billingCycle,
//     this.isLoading = false,
//     this.isSuccess = false,
//     this.error,
//     this.isVerifyingOTP = false,
//     this.registeredPhone,
//     this.businessId,
//     this.userId,
//     this.otpResendCooldown = 0,
//   });

//   RegistrationState copyWith({
//     int? currentStep,
//     BusinessRegistration? business,
//     UserRegistration? user,
//     SubscriptionPlan? selectedPlan,
//     BillingCycle? billingCycle,
//     bool? isLoading,
//     bool? isSuccess,
//     String? error,
//     bool? isVerifyingOTP,
//     String? registeredPhone,
//     String? businessId,
//     String? userId,
//     int? otpResendCooldown,
//   }) {
//     return RegistrationState(
//       currentStep: currentStep ?? this.currentStep,
//       business: business ?? this.business,
//       user: user ?? this.user,
//       selectedPlan: selectedPlan ?? this.selectedPlan,
//       billingCycle: billingCycle ?? this.billingCycle,
//       isLoading: isLoading ?? this.isLoading,
//       isSuccess: isSuccess ?? this.isSuccess,
//       error: error,
//       isVerifyingOTP: isVerifyingOTP ?? this.isVerifyingOTP,
//       registeredPhone: registeredPhone ?? this.registeredPhone,
//       businessId: businessId ?? this.businessId,
//       userId: userId ?? this.userId,
//       otpResendCooldown: otpResendCooldown ?? this.otpResendCooldown,
//     );
//   }
// }

// class RegistrationNotifier extends StateNotifier<RegistrationState> {
//   final Ref _ref;
//   final RegistrationService _registrationService;
//   final AuthService _authService;

//   RegistrationNotifier(this._ref)
//       : _registrationService = _ref.read(registrationServiceProvider),
//         _authService = _ref.read(authServiceProvider),
//         super(const RegistrationState());

//   void updateBusinessInfo(BusinessRegistration business) {
//     state = state.copyWith(business: business);
//   }

//   void updateUserInfo(UserRegistration user) {
//     state = state.copyWith(user: user);
//   }

//   void selectPlan(SubscriptionPlan plan, BillingCycle billingCycle) {
//     state = state.copyWith(selectedPlan: plan, billingCycle: billingCycle);
//   }

//   void nextStep() {
//     if (state.currentStep < 4) {
//       // 5 steps total including OTP
//       state = state.copyWith(currentStep: state.currentStep + 1, error: null);
//     }
//   }

//   void previousStep() {
//     if (state.currentStep > 0) {
//       state = state.copyWith(currentStep: state.currentStep - 1, error: null);
//     }
//   }

//   Future<void> sendRegistrationOTP(String phone) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       await _authService.sendRegistrationOTP(phone);

//       // Start resend cooldown (60 seconds)
//       _startResendCooldown();

//       state = state.copyWith(
//         isLoading: false,
//         registeredPhone: phone,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Failed to send OTP: ${e.toString()}',
//       );
//     }
//   }

//   void _startResendCooldown() {
//     const cooldownDuration = 60;
//     state = state.copyWith(otpResendCooldown: cooldownDuration);

//     // Timer.periodic passes the timer instance 't' into the callback
//     Timer.periodic(const Duration(seconds: 1), (t) {
//       final remaining = cooldownDuration - t.tick;

//       if (remaining >= 0) {
//         state = state.copyWith(otpResendCooldown: remaining);
//       } else {
//         state = state.copyWith(otpResendCooldown: 0);
//         t.cancel(); // Safely cancel using the argument
//       }
//     });
//   }

//   Future<bool> verifyRegistrationOTP(String code) async {
//     if (state.registeredPhone == null || state.user == null) {
//       state = state.copyWith(error: 'Registration data missing');
//       return false;
//     }

//     state = state.copyWith(isVerifyingOTP: true, error: null);
//     try {
//       // Create user object for registration
//       final user = User(
//         id: state.userId ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
//         name: state.user!.name,
//         phone: state.user!.phone,
//         email: state.user?.email ?? '',
//         role: state.user!.role,
//         createdAt: DateTime.now(),
//         isActive: true,
//         isVerified: true, // Mark as verified after OTP
//         businessId: state.businessId,
//         passwordHash: _hashPassword(state.user!.password),
//       );

//       await _authService.verifyOTPAndRegister(
//         state.registeredPhone!,
//         code,
//         user,
//       );

//       state = state.copyWith(
//         isVerifyingOTP: false,
//         isSuccess: true,
//       );
//       return true;
//     } catch (e) {
//       state = state.copyWith(
//         isVerifyingOTP: false,
//         error: 'OTP verification failed: ${e.toString()}',
//       );
//       return false;
//     }
//   }

//   String _hashPassword(String password) {
//     final bytes = utf8.encode(password);
//     final digest = sha256.convert(bytes);
//     return digest.toString();
//   }

//   Future<void> completeRegistration() async {
//     if (state.business == null ||
//         state.user == null ||
//         state.selectedPlan == null ||
//         state.billingCycle == null) {
//       state = state.copyWith(error: 'Please complete all registration steps');
//       return;
//     }

//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final result = await _registrationService.createTemporaryRegistration(
//         business: state.business!,
//         user: state.user!,
//         plan: state.selectedPlan!,
//         billingCycle: state.billingCycle!,
//         shop: null,
//         owner: null,
//       );

//       if (result.success) {
//         // Send OTP for verification after successful registration
//         await sendRegistrationOTP(state.user!.phone);
//         state = state.copyWith(
//           isLoading: false,
//           businessId: result.businessId,
//           userId: result.userId,
//         );
//         nextStep(); // Move to OTP verification step
//       } else {
//         state = state.copyWith(
//           isLoading: false,
//           error: result.error,
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Registration failed: ${e.toString()}',
//       );
//     }
//   }

//   void reset() {
//     state = const RegistrationState();
//   }

//   bool get canResendOTP => state.otpResendCooldown == 0;
// }

// final registrationProvider =
//     StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
//   return RegistrationNotifier(ref);
// });
