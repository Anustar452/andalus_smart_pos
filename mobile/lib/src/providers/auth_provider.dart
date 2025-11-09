import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/service/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';
// import 'package:andalus_smart_pos/src/services/auth_service.dart';
import 'package:andalus_smart_pos/src/data/repositories/user_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/otp_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/subscription_repository.dart';

// Providers - Fixed to not pass any arguments
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(AppDatabase());
});

final otpRepositoryProvider = Provider<OTPRepository>((ref) {
  return OTPRepository();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

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

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  }) : isAuthenticated = user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> sendOTP(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = _ref.read(authServiceProvider);
      await authService.sendLoginOTP(phone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOTPAndLogin(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = _ref.read(authServiceProvider);
      final user = await authService.verifyOTPAndLogin(phone, code);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void logout() {
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
