import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:andalus_smart_pos/src/data/repositories/user_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/otp_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/subscription_repository.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';
import 'package:andalus_smart_pos/src/data/models/otp.dart';

class AuthService {
  final UserRepository _userRepository;
  final OTPRepository _otpRepository;
  final SubscriptionRepository _subscriptionRepository;

  AuthService({
    required UserRepository userRepository,
    required OTPRepository otpRepository,
    required SubscriptionRepository subscriptionRepository,
  })  : _userRepository = userRepository,
        _otpRepository = otpRepository,
        _subscriptionRepository = subscriptionRepository;

  // Hash password method
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verify password method
  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  Future<void> sendLoginOTP(String phone) async {
    // Check if user exists
    final user = await _userRepository.getUserByPhone(phone);
    if (user == null) {
      throw Exception(
          'User not found. Please contact admin to create account.');
    }

    if (!user.isActive) {
      throw Exception('Account is deactivated. Please contact admin.');
    }

    // Create and save OTP
    final otp = OTP.create(phone: phone, type: 'login');
    await _otpRepository.createOTP(otp);

    // In real app, send SMS here
    print('OTP for $phone: ${otp.code}'); // Remove in production
  }

  Future<User> verifyOTPAndLogin(String phone, String code) async {
    // Verify OTP
    final otp = await _otpRepository.getValidOTP(phone, code, 'login');
    if (otp == null) {
      throw Exception('Invalid or expired OTP');
    }

    // Get user
    final user = await _userRepository.getUserByPhone(phone);
    if (user == null) {
      throw Exception('User not found');
    }

    // Check subscription for non-admin users
    if (!user.isAdmin && user.businessId != null) {
      final hasValidSubscription =
          await _subscriptionRepository.hasValidSubscription(user.businessId!);
      if (!hasValidSubscription) {
        throw Exception(
            'Subscription expired. Please renew to continue using the app.');
      }
    }

    // Mark OTP as used
    await _otpRepository.markOTPAsUsed(otp.id);

    // Update last login
    await _userRepository.updateLastLogin(user.id);

    return user;
  }

  Future<void> createUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
    required String businessId,
  }) async {
    // Check if phone already exists
    final existingUser = await _userRepository.getUserByPhone(phone);
    if (existingUser != null) {
      throw Exception('User with this phone already exists');
    }

    // Create user
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      role: role,
      createdAt: DateTime.now(),
      businessId: businessId,
      passwordHash: _hashPassword(password), // Hash the password
    );

    await _userRepository.createUser(user);
  }

  Future<void> changePassword(String userId, String newPassword) async {
    final user = await _userRepository.getUserById(userId);
    if (user == null) throw Exception('User not found');

    final updatedUser = user.copyWith(passwordHash: _hashPassword(newPassword));
    await _userRepository.updateUser(updatedUser);
  }

  // Method to verify password for traditional login (if needed later)
  Future<User?> verifyPassword(String phone, String password) async {
    final user = await _userRepository.getUserByPhone(phone);
    if (user == null || user.passwordHash == null) return null;

    if (_verifyPassword(password, user.passwordHash!)) {
      await _userRepository.updateLastLogin(user.id);
      return user;
    }

    return null;
  }
}
