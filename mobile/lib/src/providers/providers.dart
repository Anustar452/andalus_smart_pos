// src/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/repositories/user_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/otp_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/subscription_repository.dart';
import 'package:andalus_smart_pos/src/service/auth_service.dart';
import 'package:andalus_smart_pos/src/service/registration_service.dart';

// Repository Providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final otpRepositoryProvider = Provider<OTPRepository>((ref) {
  return OTPRepository();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

// Service Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    userRepository: ref.read(userRepositoryProvider),
    otpRepository: ref.read(otpRepositoryProvider),
    subscriptionRepository: ref.read(subscriptionRepositoryProvider),
  );
});

final registrationServiceProvider = Provider<RegistrationService>((ref) {
  return RegistrationService(
    userRepository: ref.read(userRepositoryProvider),
    subscriptionRepository: ref.read(subscriptionRepositoryProvider),
  );
});
