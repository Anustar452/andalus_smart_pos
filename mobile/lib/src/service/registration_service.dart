import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:andalus_smart_pos/src/data/models/registration.dart';
import 'package:andalus_smart_pos/src/data/repositories/user_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/subscription_repository.dart';

class RegistrationService {
  final UserRepository _userRepository;
  final SubscriptionRepository _subscriptionRepository;

  RegistrationService({
    required UserRepository userRepository,
    required SubscriptionRepository subscriptionRepository,
  })  : _userRepository = userRepository,
        _subscriptionRepository = subscriptionRepository;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<RegistrationResult> registerBusiness({
    required BusinessRegistration business,
    required UserRegistration user,
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
  }) async {
    final db = await AppDatabase.database;

    try {
      await db.transaction((txn) async {
        // 1. Create business profile
        final businessId = 'business_${DateTime.now().millisecondsSinceEpoch}';
        final now = DateTime.now().millisecondsSinceEpoch;

        await txn.insert('business_profile', {
          'business_id': businessId,
          ...business.toMap(),
          'currency': 'ETB',
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        });

        // 2. Create user account
        final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        final userModel = User(
          id: userId,
          name: user.name,
          phone: user.phone,
          // email: user.email,
          role: user.role,
          createdAt: DateTime.now(),
          isActive: true,
          isVerified: false,
          businessId: businessId,
          passwordHash: _hashPassword(user.password), email: '',
        );

        await txn.insert('users', userModel.toMap());

        // 3. Create initial subscription (14-day trial)
        final subscription = Subscription(
          id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
          businessId: businessId,
          userId: userId,
          plan: plan,
          billingCycle: billingCycle,
          status: SubscriptionStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 14)), // 14-day trial
          amount: 0, // Free trial
          currency: 'ETB',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await txn.insert('subscriptions', subscription.toMap());
      });

      return RegistrationResult.success();
    } catch (e) {
      return RegistrationResult.failure('Registration failed: $e');
    }
  }

  Future<PaymentResult> processSubscriptionPayment({
    required String businessId,
    required String userId,
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    required String paymentMethod, // 'telebirr', 'bank', 'card'
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      // Calculate amount
      final amount = plan.getPrice(billingCycle);

      // TODO: Integrate with actual payment gateway (Telebirr, CBE, etc.)
      // For now, simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Simulate payment success (90% success rate for demo)
      final isSuccess = DateTime.now().millisecond % 10 != 0;

      if (!isSuccess) {
        return PaymentResult.failure(
            'Payment processing failed. Please try again.');
      }

      // Create paid subscription
      final now = DateTime.now();
      DateTime endDate;

      if (billingCycle == BillingCycle.monthly) {
        endDate = now.add(const Duration(days: 30));
      } else {
        endDate = now.add(const Duration(days: 365));
      }

      final subscription = Subscription(
        id: 'sub_${now.millisecondsSinceEpoch}',
        businessId: businessId,
        userId: userId,
        plan: plan,
        billingCycle: billingCycle,
        status: SubscriptionStatus.active,
        startDate: now,
        endDate: endDate,
        amount: amount,
        currency: 'ETB',
        isActive: true,
        paymentReference: 'ref_${now.millisecondsSinceEpoch}',
        createdAt: now,
        updatedAt: now,
      );

      await _subscriptionRepository.createSubscription(subscription);

      return PaymentResult.success(
        paymentReference: subscription.paymentReference,
        transactionId: 'txn_${now.millisecondsSinceEpoch}',
      );
    } catch (e) {
      return PaymentResult.failure('Payment processing error: $e');
    }
  }

  Future<bool> checkBusinessPhoneExists(String phone) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'business_profile',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    return result.isNotEmpty;
  }

  Future<bool> checkUserPhoneExists(String phone) async {
    final user = await _userRepository.getUserByPhone(phone);
    return user != null;
  }
}

class RegistrationResult {
  final bool success;
  final String? error;
  final String? businessId;
  final String? userId;

  const RegistrationResult({
    required this.success,
    this.error,
    this.businessId,
    this.userId,
  });

  factory RegistrationResult.success() {
    return RegistrationResult(success: true);
  }

  factory RegistrationResult.failure(String error) {
    return RegistrationResult(success: false, error: error);
  }
}
