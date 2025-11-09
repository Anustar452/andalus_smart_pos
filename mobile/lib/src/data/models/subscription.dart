class Subscription {
  final String id;
  final String businessId;
  final String userId;
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String currency;
  final bool isActive;
  final String? paymentReference;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.plan,
    required this.billingCycle,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.currency = 'ETB',
    this.isActive = true,
    this.paymentReference,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'subscription_id': id,
      'business_id': businessId,
      'user_id': userId,
      'plan': plan.id, // Use plan.id instead of plan.name
      'billing_cycle': billingCycle.name,
      'status': status.name,
      'amount': amount,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'currency': currency,
      'payment_reference': paymentReference,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['subscription_id'],
      businessId: map['business_id'],
      userId: map['user_id'],
      plan: SubscriptionPlan.fromString(map['plan']), // Use fromString method
      billingCycle:
          BillingCycle.values.firstWhere((e) => e.name == map['billing_cycle']),
      status:
          SubscriptionStatus.values.firstWhere((e) => e.name == map['status']),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date']),
      amount: map['amount'],
      currency: map['currency'] ?? 'ETB',
      isActive: map['is_active'] == 1,
      paymentReference: map['payment_reference'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  bool get isExpired => endDate.isBefore(DateTime.now());
  bool get isValid =>
      isActive && !isExpired && status == SubscriptionStatus.active;

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  String get statusDisplay {
    if (!isActive) return 'Inactive';
    if (isExpired) return 'Expired';
    if (status == SubscriptionStatus.pastDue) return 'Past Due';
    if (status == SubscriptionStatus.canceled) return 'Canceled';
    return 'Active';
  }

  Subscription renew({String? paymentReference}) {
    final now = DateTime.now();
    DateTime newEndDate;

    if (billingCycle == BillingCycle.monthly) {
      newEndDate = now.add(const Duration(days: 30));
    } else {
      newEndDate = now.add(const Duration(days: 365));
    }

    return Subscription(
      id: 'sub_${now.millisecondsSinceEpoch}',
      businessId: businessId,
      userId: userId,
      plan: plan,
      billingCycle: billingCycle,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: newEndDate,
      amount: amount,
      currency: currency,
      isActive: true,
      paymentReference: paymentReference,
      createdAt: createdAt,
      updatedAt: now,
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final int maxProducts;
  final int maxUsers;
  final int maxStores;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.maxProducts,
    required this.maxUsers,
    required this.maxStores,
  });

  static const basic = SubscriptionPlan(
    id: 'basic',
    name: 'Basic',
    description: 'Perfect for small shops and startups',
    monthlyPrice: 299,
    yearlyPrice: 2990, // 2 months free
    features: [
      'Up to 100 products',
      'Basic sales reports',
      'Single device',
      'Email support',
      'Basic inventory management',
    ],
    maxProducts: 100,
    maxUsers: 1,
    maxStores: 1,
  );

  static const professional = SubscriptionPlan(
    id: 'professional',
    name: 'Professional',
    description: 'For growing businesses with multiple users',
    monthlyPrice: 799,
    yearlyPrice: 7990, // 2 months free
    features: [
      'Unlimited products',
      'Advanced analytics',
      'Multi-device support',
      'Priority support',
      'Inventory management',
      'Customer management',
      'Basic reporting',
    ],
    maxProducts: -1, // Unlimited
    maxUsers: 3,
    maxStores: 3,
  );

  static const enterprise = SubscriptionPlan(
    id: 'enterprise',
    name: 'Enterprise',
    description: 'Enterprise-grade features for large businesses',
    monthlyPrice: 1499,
    yearlyPrice: 14990, // 2 months free
    features: [
      'All Professional features',
      'Custom branding',
      'API access',
      'Dedicated account manager',
      'Advanced reporting',
      'Multi-store management',
      'Priority phone support',
    ],
    maxProducts: -1, // Unlimited
    maxUsers: -1, // Unlimited
    maxStores: -1, // Unlimited
  );

  static List<SubscriptionPlan> get all => [basic, professional, enterprise];

  // Add a method to convert string to SubscriptionPlan
  static SubscriptionPlan fromString(String planId) {
    switch (planId) {
      case 'basic':
        return basic;
      case 'professional':
        return professional;
      case 'enterprise':
        return enterprise;
      default:
        return basic; // Default fallback
    }
  }

  double getPrice(BillingCycle cycle) {
    return cycle == BillingCycle.monthly ? monthlyPrice : yearlyPrice;
  }

  String getFormattedPrice(BillingCycle cycle) {
    final price = getPrice(cycle);
    return 'ETB ${price.toStringAsFixed(0)}${cycle == BillingCycle.monthly ? '/month' : '/year'}';
  }

  String get savingsInfo {
    final yearlySavings = (monthlyPrice * 12) - yearlyPrice;
    return 'Save ETB ${yearlySavings.toStringAsFixed(0)} with yearly billing';
  }

  bool allowsUnlimitedProducts() => maxProducts == -1;
  bool allowsUnlimitedUsers() => maxUsers == -1;
  bool allowsUnlimitedStores() => maxStores == -1;
}

enum BillingCycle {
  monthly('Monthly'),
  yearly('Yearly');

  final String displayName;

  const BillingCycle(this.displayName);
}

enum SubscriptionStatus {
  active('Active'),
  inactive('Inactive'),
  canceled('Canceled'),
  pastDue('Past Due'),
  pending('Pending');

  final String displayName;

  const SubscriptionStatus(this.displayName);
}

class PaymentResult {
  final bool success;
  final String? paymentReference;
  final String? error;
  final String? transactionId;

  const PaymentResult({
    required this.success,
    this.paymentReference,
    this.error,
    this.transactionId,
  });

  factory PaymentResult.success(
      {String? paymentReference, String? transactionId}) {
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
