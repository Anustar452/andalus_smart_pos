// mobile/lib/src/data/models/settings.dart
// Model representing application settings for the POS system. includes new settings for credit system and stock notifications.
//dark mode language selection currency selection calander format etc can be selected from
class AppSettings {
  final String shopName;
  final String shopNameAm;
  final String address;
  final String phone;
  final String tinNumber;
  final String currency;
  final bool enableTax;
  final double taxRate;
  final bool enableDiscounts;
  final bool autoPrintReceipts;
  final String defaultPaymentMethod;
  final bool enableSync;
  final int syncInterval;

  // New fields for enhanced settings
  final bool enableCreditSystem;
  final double defaultCreditLimit;
  final String defaultPaymentTerms;
  final bool enableCustomerSelection;
  final bool lowStockNotifications;
  final int lowStockThreshold;

  AppSettings({
    required this.shopName,
    required this.shopNameAm,
    required this.address,
    required this.phone,
    required this.tinNumber,
    required this.currency,
    required this.enableTax,
    required this.taxRate,
    required this.enableDiscounts,
    required this.autoPrintReceipts,
    required this.defaultPaymentMethod,
    required this.enableSync,
    required this.syncInterval,

    // New fields with default values
    this.enableCreditSystem = true,
    this.defaultCreditLimit = 1000.0,
    this.defaultPaymentTerms = '30',
    this.enableCustomerSelection = true,
    this.lowStockNotifications = true,
    this.lowStockThreshold = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'shopNameAm': shopNameAm,
      'address': address,
      'phone': phone,
      'tinNumber': tinNumber,
      'currency': currency,
      'enableTax': enableTax,
      'taxRate': taxRate,
      'enableDiscounts': enableDiscounts,
      'autoPrintReceipts': autoPrintReceipts,
      'defaultPaymentMethod': defaultPaymentMethod,
      'enableSync': enableSync,
      'syncInterval': syncInterval,
      'enableCreditSystem': enableCreditSystem,
      'defaultCreditLimit': defaultCreditLimit,
      'defaultPaymentTerms': defaultPaymentTerms,
      'enableCustomerSelection': enableCustomerSelection,
      'lowStockNotifications': lowStockNotifications,
      'lowStockThreshold': lowStockThreshold,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      shopName: map['shopName'] ?? 'Andalus Smart POS',
      shopNameAm: map['shopNameAm'] ?? 'አንዳሉስ ማርቲን ፖስ',
      address: map['address'] ?? 'Addis Ababa, Ethiopia',
      phone: map['phone'] ?? '+251 911 234 567',
      tinNumber: map['tinNumber'] ?? 'TIN-123456789',
      currency: map['currency'] ?? 'ETB',
      enableTax: map['enableTax'] ?? false,
      taxRate: map['taxRate'] ?? 0.15,
      enableDiscounts: map['enableDiscounts'] ?? true,
      autoPrintReceipts: map['autoPrintReceipts'] ?? false,
      defaultPaymentMethod: map['defaultPaymentMethod'] ?? 'cash',
      enableSync: map['enableSync'] ?? true,
      syncInterval: map['syncInterval'] ?? 5,
      enableCreditSystem: map['enableCreditSystem'] ?? true,
      defaultCreditLimit: map['defaultCreditLimit'] ?? 1000.0,
      defaultPaymentTerms: map['defaultPaymentTerms'] ?? '30',
      enableCustomerSelection: map['enableCustomerSelection'] ?? true,
      lowStockNotifications: map['lowStockNotifications'] ?? true,
      lowStockThreshold: map['lowStockThreshold'] ?? 10,
    );
  }

  AppSettings copyWith({
    String? shopName,
    String? shopNameAm,
    String? address,
    String? phone,
    String? tinNumber,
    String? currency,
    bool? enableTax,
    double? taxRate,
    bool? enableDiscounts,
    bool? autoPrintReceipts,
    String? defaultPaymentMethod,
    bool? enableSync,
    int? syncInterval,
    bool? enableCreditSystem,
    double? defaultCreditLimit,
    String? defaultPaymentTerms,
    bool? enableCustomerSelection,
    bool? lowStockNotifications,
    int? lowStockThreshold,
  }) {
    return AppSettings(
      shopName: shopName ?? this.shopName,
      shopNameAm: shopNameAm ?? this.shopNameAm,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      tinNumber: tinNumber ?? this.tinNumber,
      currency: currency ?? this.currency,
      enableTax: enableTax ?? this.enableTax,
      taxRate: taxRate ?? this.taxRate,
      enableDiscounts: enableDiscounts ?? this.enableDiscounts,
      autoPrintReceipts: autoPrintReceipts ?? this.autoPrintReceipts,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      enableSync: enableSync ?? this.enableSync,
      syncInterval: syncInterval ?? this.syncInterval,
      enableCreditSystem: enableCreditSystem ?? this.enableCreditSystem,
      defaultCreditLimit: defaultCreditLimit ?? this.defaultCreditLimit,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      enableCustomerSelection:
          enableCustomerSelection ?? this.enableCustomerSelection,
      lowStockNotifications:
          lowStockNotifications ?? this.lowStockNotifications,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }
}
