// src/service/auth_service.dart
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

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> verifyOTPAndRegister(
    String phone,
    String code,
    User user,
  ) async {
    print('🔐 OTP Registration for: $phone');

    try {
      // 1. Verify OTP
      final otp = await _otpRepository.getValidOTP(phone, code, 'registration');
      if (otp == null) {
        throw Exception('Invalid or expired OTP code. Please try again.');
      }

      // 2. Mark OTP as used
      await _otpRepository.markOTPAsUsed(otp.id);

      // 3. Check if user already exists
      final existingUser = await _userRepository.getUserByPhone(phone);
      if (existingUser != null) {
        throw Exception(
            'An account already exists with this phone number. Please login instead.');
      }

      // 4. Hash the password before saving
      final hashedPassword = _hashPassword(user.passwordHash ?? '');

      // 5. Create new user with verified status
      final newUser = user.copyWith(
        phone: phone,
        passwordHash: hashedPassword,
        isVerified: true,
        isActive: true,
      );
      await _userRepository.createUser(newUser);

      // 6. Update last login
      await _userRepository.updateLastLogin(newUser.id);

      print('✅ Registration successful for: ${user.name}');
    } catch (e) {
      print('❌ OTP registration error: $e');
      rethrow;
    }
  }

  // Password-based login
  Future<User> loginWithPassword(String phone, String password) async {
    print('🔐 Password login attempt for: $phone');

    try {
      // Get user by phone
      final user = await _userRepository.getUserByPhone(phone);
      if (user == null) {
        throw Exception(
            'No account found with this phone number. Please register first.');
      }

      if (!user.isActive) {
        throw Exception('Account is deactivated. Please contact support.');
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        throw Exception('Invalid password. Please try again.');
      }

      if (!user.isVerified) {
        throw Exception('Account not verified. Please complete verification.');
      }

      // Update last login
      await _userRepository.updateLastLogin(user.id);

      // Check subscription status
      final hasValidSubscription = await _subscriptionRepository
          .hasValidSubscription(user.businessId ?? '');
      if (!hasValidSubscription) {
        print('⚠️ No active subscription found for user: ${user.id}');
      }

      print('✅ Password login successful for: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Password login error: $e');
      rethrow;
    }
  }

  // Enhanced OTP-based login with better error handling
  Future<User> loginWithOTP(String phone, String code) async {
    print('🔐 OTP login attempt for: $phone');

    // Validate inputs
    if (phone.isEmpty) {
      throw Exception('Phone number not set');
    }

    if (code.isEmpty || code.length != 6) {
      throw Exception('Please enter a valid 6-digit OTP code');
    }

    try {
      // Verify OTP
      final otp = await _otpRepository.getValidOTP(phone, code, 'login');
      if (otp == null) {
        throw Exception('Invalid or expired OTP code. Please try again.');
      }

      // Mark OTP as used
      await _otpRepository.markOTPAsUsed(otp.id);

      // Get user by phone
      final user = await _userRepository.getUserByPhone(phone);
      if (user == null) {
        throw Exception('User not found. Please complete registration.');
      }

      if (!user.isActive) {
        throw Exception('Account is deactivated. Please contact support.');
      }

      // Update last login
      await _userRepository.updateLastLogin(user.id);

      // Check subscription status
      final hasValidSubscription = await _subscriptionRepository
          .hasValidSubscription(user.businessId ?? '');
      if (!hasValidSubscription) {
        print('⚠️ No active subscription found for user: ${user.id}');
      }

      print('✅ OTP login successful for: ${user.name}');
      return user;
    } catch (e) {
      print('❌ OTP login error: $e');
      rethrow;
    }
  }

  // Enhanced OTP sending with validation
  Future<void> sendLoginOTP(String phone) async {
    print('📱 Sending login OTP for: $phone');

    // Validate phone number
    if (phone.isEmpty || !RegExp(r'^\+251[0-9]{9}$').hasMatch(phone)) {
      throw Exception('Please enter a valid Ethiopian phone number (+251...)');
    }

    // Check if user exists
    final user = await _userRepository.getUserByPhone(phone);
    if (user == null) {
      throw Exception(
          'No account found with this phone number. Please register first.');
    }

    if (!user.isActive) {
      throw Exception('Account is deactivated. Please contact support.');
    }

    await _sendOTP(phone, 'login');
  }

  Future<void> sendRegistrationOTP(String phone) async {
    print('📝 Sending registration OTP for: $phone');

    // Validate phone number
    if (phone.isEmpty || !RegExp(r'^\+251[0-9]{9}$').hasMatch(phone)) {
      throw Exception('Please enter a valid Ethiopian phone number (+251...)');
    }

    // Check if user already exists
    final existingUser = await _userRepository.getUserByPhone(phone);
    if (existingUser != null) {
      throw Exception(
          'An account already exists with this phone number. Please login instead.');
    }

    await _sendOTP(phone, 'registration');
  }

  // Generic OTP sending method for verification
  Future<void> sendOTP(String phone) async {
    print('📱 Sending OTP for: $phone');

    // Validate phone number
    if (phone.isEmpty || !RegExp(r'^\+251[0-9]{9}$').hasMatch(phone)) {
      throw Exception('Please enter a valid Ethiopian phone number (+251...)');
    }

    await _sendOTP(phone, 'verification');
  }

  // Enhanced OTP sending with better logging
  Future<void> _sendOTP(String phone, String type) async {
    try {
      // Generate OTP
      final otp = OTP.create(phone: phone, type: type);

      // Store OTP
      await _otpRepository.createOTP(otp);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Enhanced logging for demo purposes
      print('✅ OTP sent successfully');
      print('📱 Phone: $phone');
      print('🔑 OTP Code: ${otp.code}');
      print('📝 Type: $type');
      print('⏰ Expires: ${otp.expiresAt}');
      print('🎯 DEMO - Use this code: ${otp.code}');
    } catch (e) {
      print('❌ OTP send error: $e');
      throw Exception('Failed to send OTP. Please try again.');
    }
  }

  // Enhanced OTP verification for general use
  Future<void> verifyOTP(String phone, String code,
      {String type = 'verification'}) async {
    print('🔐 Verifying OTP for: $phone');

    if (phone.isEmpty) {
      throw Exception('Phone number not set');
    }

    if (code.isEmpty || code.length != 6) {
      throw Exception('Please enter a valid 6-digit OTP code');
    }

    try {
      final otp = await _otpRepository.getValidOTP(phone, code, type);
      if (otp == null) {
        throw Exception('Invalid or expired OTP code. Please try again.');
      }

      await _otpRepository.markOTPAsUsed(otp.id);
      print('✅ OTP verified successfully for: $phone');
    } catch (e) {
      print('❌ OTP verification error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    // Clear any local authentication state
    print('🚪 User logged out');
  }

  // Utility method to clean up expired OTPs
  Future<void> cleanupExpiredOTPs() async {
    await _otpRepository.cleanExpiredOTPs();
  }
}
