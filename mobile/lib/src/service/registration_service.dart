// src/service/registration_service.dart
// Service for handling user and shop registration logic.
import 'package:andalus_smart_pos/src/data/models/registration.dart';
import 'package:andalus_smart_pos/src/data/repositories/subscription_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/user_repository.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:andalus_smart_pos/src/data/models/shop_registration.dart';

class RegistrationService {
  final UserRepository _userRepository;
  final SubscriptionRepository _subscriptionRepository;

  RegistrationService({
    required UserRepository userRepository,
    required SubscriptionRepository subscriptionRepository,
  })  : _userRepository = userRepository,
        _subscriptionRepository = subscriptionRepository;
  // Convenience method to create a temporary registration using ShopRegistration directly.
  Future<RegistrationResult> createTemporaryRegistrationFromShop({
    required ShopRegistration shop,
    required UserRegistration user,
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    required OwnerRegistration owner,
    BusinessRegistration? business, // <--- Add '?' here
  }) async {
    final db = await AppDatabase.database;

    try {
      // Check if phone numbers already exist
      // ShopRegistration does not expose a `phone` getter, so read it from toMap().
      final shopPhone = shop.toMap()['phone']?.toString() ?? '';
      final shopPhoneExists = await checkShopPhoneExists(shopPhone);
      if (shopPhoneExists) {
        return RegistrationResult.failure(
            'Shop phone number already registered');
      }

      final userPhoneExists = await checkUserPhoneExists(user.phone);
      if (userPhoneExists) {
        return RegistrationResult.failure(
            'User phone number already registered');
      }

      String? tempShopId;
      String? tempOwnerId;

      await db.transaction((txn) async {
        // 1. Create temporary shop profile
        tempShopId = 'temp_shop_${DateTime.now().millisecondsSinceEpoch}';
        final now = DateTime.now().millisecondsSinceEpoch;

        await txn.insert('business_profile', {
          'business_id': tempShopId,
          ...shop.toMap(),
          'currency': 'ETB',
          'is_active': 0, // Not active until payment
          'created_at': now,
          'updated_at': now,
        });

        // 2. Create temporary owner account
        tempOwnerId = 'temp_user_${DateTime.now().millisecondsSinceEpoch}';

        // Handle email properly
        final userEmail =
            user.email?.trim().isEmpty == true ? '' : user.email?.trim() ?? '';

        final userModel = User(
          id: tempOwnerId!,
          name: user.name,
          phone: user.phone,
          email: userEmail,
          role: user.role,
          createdAt: DateTime.now(),
          isActive: false, // Not active until payment
          isVerified: false,
          businessId: tempShopId,
          passwordHash: _hashPassword(user.password),
        );

        await txn.insert('users', userModel.toMap());

        // 3. Create pending subscription
        final subscription = Subscription(
          id: 'pending_sub_${DateTime.now().millisecondsSinceEpoch}',
          businessId: tempShopId!,
          userId: tempOwnerId!,
          plan: plan,
          billingCycle: billingCycle,
          status: SubscriptionStatus.pending,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 14)),
          amount: plan.getPrice(billingCycle),
          currency: 'ETB',
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await txn.insert('subscriptions', subscription.toMap());
      });

      return RegistrationResult.success(
        businessId: tempShopId,
        userId: tempOwnerId,
      );
    } catch (e) {
      print('Registration error: $e');
      return RegistrationResult.failure('Registration failed: ${e.toString()}');
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<RegistrationResult> createTemporaryRegistration({
    BusinessRegistration? business,
    UserRegistration? user,
    ShopRegistration? shop,
    OwnerRegistration? owner,
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
  }) async {
    final db = await AppDatabase.database;

    try {
      String? phoneToCheck;

      // Determine which phone to check based on provided data
      if (shop != null) {
        final shopPhone = shop.phoneNumber;
        phoneToCheck = shopPhone;
      } else if (business != null) {
        phoneToCheck = business.phone;
      }

      if (phoneToCheck != null) {
        final shopPhoneExists = await checkShopPhoneExists(phoneToCheck);
        if (shopPhoneExists) {
          return RegistrationResult.failure('Phone number already registered');
        }
      }

      String? userPhoneToCheck;
      if (owner != null) {
        userPhoneToCheck = owner.phone;
      } else if (user != null) {
        userPhoneToCheck = user.phone;
      }

      if (userPhoneToCheck != null) {
        final userPhoneExists = await checkUserPhoneExists(userPhoneToCheck);
        if (userPhoneExists) {
          return RegistrationResult.failure(
              'User phone number already registered');
        }
      }

      String? tempShopId;
      String? tempOwnerId;

      await db.transaction((txn) async {
        // 1. Create temporary business profile
        tempShopId = 'temp_shop_${DateTime.now().millisecondsSinceEpoch}';
        final now = DateTime.now().millisecondsSinceEpoch;

        if (shop != null) {
          // Map ShopRegistration to business_profile table schema
          final shopMap = shop.toMap();
          await txn.insert('business_profile', {
            'business_id': tempShopId,
            'name': shopMap['shop_name'], // Map to 'name' column
            'name_am': shopMap[
                'shop_name'], // Use same name for Amharic or get from somewhere
            'business_type': shopMap['shop_category'], // Map to 'business_type'
            'phone': shopMap['phone_number'], // Map to 'phone'
            'email': '', // Optional field
            'address': shopMap['business_address'], // Map to 'address'
            'city': shopMap['city'],
            'region':
                shopMap['country'], // Map country to region or adjust as needed
            'tin_number':
                'TEMP_${DateTime.now().millisecondsSinceEpoch}', // Generate temp TIN
            'vat_number': null,
            'business_license': null,
            'owner_name': '', // Will be set from owner registration
            'owner_phone': '', // Will be set from owner registration
            'owner_email': null,
            'currency': 'ETB',
            'logo_path': shopMap['shop_logo'],
            'receipt_header': null,
            'receipt_footer': null,
            'is_active': 0,
            'created_at': now,
            'updated_at': now,
          });
        } else if (business != null) {
          // Use BusinessRegistration data (existing logic)
          await txn.insert('business_profile', {
            'business_id': tempShopId,
            ...business.toMap(),
            'currency': 'ETB',
            'is_active': 0,
            'created_at': now,
            'updated_at': now,
          });
        }

        // 2. Create temporary owner account
        tempOwnerId = 'temp_user_${DateTime.now().millisecondsSinceEpoch}';

        // In registration_service.dart - fix the user creation
        User userModel;
        if (owner != null) {
          // Handle email properly - use null if empty
          final userEmail =
              owner.email?.trim().isEmpty == true ? null : owner.email?.trim();

          userModel = User(
            id: tempOwnerId!,
            name: owner.fullName,
            phone: owner.phone,
            email: userEmail, // Can be null now
            role: UserRole.owner,
            createdAt: DateTime.now(),
            isActive: false,
            isVerified: false,
            businessId: tempShopId,
            passwordHash: _hashPassword(owner.password),
          );
        } else if (user != null) {
          // Use UserRegistration data - ensure email is unique
          final uniqueEmail = user.email?.isNotEmpty == true
              ? user.email
              : 'user_${DateTime.now().millisecondsSinceEpoch}@temp.com';

          userModel = User(
            id: tempOwnerId!,
            name: user.name,
            phone: user.phone,
            email: uniqueEmail!, // Ensure unique email
            role: user.role,
            createdAt: DateTime.now(),
            isActive: false,
            isVerified: false,
            businessId: tempShopId,
            passwordHash: _hashPassword(user.password),
          );
        } else {
          throw Exception('No user data provided');
        }

        await txn.insert('users', userModel.toMap());

        // 3. Update business profile with owner information
        if (owner != null && shop != null) {
          await txn.update(
            'business_profile',
            {
              'owner_name': owner.fullName,
              'owner_phone': owner.phone,
              'owner_email': owner.email,
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'business_id = ?',
            whereArgs: [tempShopId],
          );
        }

        // 4. Create pending subscription
        final subscription = Subscription(
          id: 'pending_sub_${DateTime.now().millisecondsSinceEpoch}',
          businessId: tempShopId!,
          userId: tempOwnerId!,
          plan: plan,
          billingCycle: billingCycle,
          status: SubscriptionStatus.pending,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 14)),
          amount: plan.getPrice(billingCycle),
          currency: 'ETB',
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await txn.insert('subscriptions', subscription.toMap());
      });

      return RegistrationResult.success(
        businessId: tempShopId,
        userId: tempOwnerId,
      );
    } catch (e) {
      print('Registration error: $e');
      return RegistrationResult.failure('Registration failed: ${e.toString()}');
    }
  }

  Future<PaymentResult> activateAccountAfterPayment({
    required String businessId,
    required String userId,
    required String paymentReference,
    required String transactionId,
  }) async {
    final db = await AppDatabase.database;

    try {
      await db.transaction((txn) async {
        // 1. Activate business
        await txn.update(
          'business_profile',
          {
            'is_active': 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'business_id = ?',
          whereArgs: [businessId],
        );

        // 2. Activate user
        await txn.update(
          'users',
          {
            'is_active': 1,
            'is_verified': 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        // 3. Activate subscription and update payment info
        await txn.update(
          'subscriptions',
          {
            'is_active': 1,
            'status': 'active',
            'payment_reference': paymentReference,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'business_id = ? AND user_id = ?',
          whereArgs: [businessId, userId],
        );
      });

      return PaymentResult.success(
        paymentReference: paymentReference,
        transactionId: transactionId,
      );
    } catch (e) {
      return PaymentResult.failure('Account activation failed: $e');
    }
  }

  Future<bool> checkShopPhoneExists(String phone) async {
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

// Add these result classes at the bottom of the file
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

  factory RegistrationResult.success({String? businessId, String? userId}) {
    return RegistrationResult(
      success: true,
      businessId: businessId,
      userId: userId,
    );
  }

  factory RegistrationResult.failure(String error) {
    return RegistrationResult(success: false, error: error);
  }
}

class PaymentResult {
  final bool success;
  final String? error;
  final String? paymentReference;
  final String? transactionId;

  const PaymentResult({
    required this.success,
    this.error,
    this.paymentReference,
    this.transactionId,
  });

  factory PaymentResult.success({
    required String paymentReference,
    required String transactionId,
  }) {
    return PaymentResult(
      success: true,
      paymentReference: paymentReference,
      transactionId: transactionId,
    );
  }

  factory PaymentResult.failure(String error) {
    return PaymentResult(success: false, error: error);
  }
}
