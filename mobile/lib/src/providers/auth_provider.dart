// src/providers/auth_provider.dart
import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/service/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';
import 'package:andalus_smart_pos/src/data/repositories/user_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/otp_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/subscription_repository.dart';

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

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    userRepository: ref.read(userRepositoryProvider),
    otpRepository: ref.read(otpRepositoryProvider),
    subscriptionRepository: ref.read(subscriptionRepositoryProvider),
  );
});

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final AuthMethod authMethod;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.authMethod = AuthMethod.none,
  }) : isAuthenticated = user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    AuthMethod? authMethod,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      authMethod: authMethod ?? this.authMethod,
    );
  }
}

enum AuthMethod {
  none,
  password,
  otp,
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> loginWithPassword(String phone, String password) async {
    print('🔐 Password login for: $phone');
    state = state.copyWith(
        isLoading: true, error: null, authMethod: AuthMethod.password);

    try {
      final authService = _ref.read(authServiceProvider);
      final user = await authService.loginWithPassword(phone, password);
      state = state.copyWith(user: user, isLoading: false);
      print('✅ Password login successful for: ${user.name}');
    } catch (e) {
      print('❌ Password login error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> sendOTP(String phone) async {
    print('📱 Sending OTP for: $phone');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = _ref.read(authServiceProvider);
      await authService.sendLoginOTP(phone);
      state = state.copyWith(isLoading: false, authMethod: AuthMethod.otp);
      print('✅ OTP sent successfully');
    } catch (e) {
      print('❌ OTP send error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOTPAndLogin(String phone, String code) async {
    print('🔐 Verifying OTP and logging in: $phone');
    state = state.copyWith(
        isLoading: true, error: null, authMethod: AuthMethod.otp);

    try {
      final authService = _ref.read(authServiceProvider);
      final user = await authService.loginWithOTP(phone, code);
      state = state.copyWith(user: user, isLoading: false);
      print('✅ OTP login successful for: ${user.name}');
    } catch (e, stackTrace) {
      print('❌ OTP login error: $e');
      print('📋 FULL STACK TRACE: $stackTrace');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void logout() {
    print('🚪 Logging out user');
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Check if user exists (for navigation)
  Future<bool> checkUserExists(String phone) async {
    try {
      final userRepository = _ref.read(userRepositoryProvider);
      final user = await userRepository.getUserByPhone(phone);
      return user != null;
    } catch (e) {
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
