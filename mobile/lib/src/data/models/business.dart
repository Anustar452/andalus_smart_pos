class BusinessType {
  final String id;
  final String name;
  final String nameAm;
  final String description;

  const BusinessType({
    required this.id,
    required this.name,
    required this.nameAm,
    required this.description,
  });

  static const List<BusinessType> allTypes = [
    BusinessType(
      id: 'retail',
      name: 'Retail Shop',
      nameAm: 'የገበያ ሱቅ',
      description: 'General retail store selling various products',
    ),
    BusinessType(
      id: 'supermarket',
      name: 'Supermarket',
      nameAm: 'ሱፐርማርኬት',
      description: 'Large retail store with multiple departments',
    ),
    BusinessType(
      id: 'restaurant',
      name: 'Restaurant/Cafe',
      nameAm: 'ምግብ ቤት/ካፌ',
      description: 'Food and beverage service establishment',
    ),
    BusinessType(
      id: 'pharmacy',
      name: 'Pharmacy',
      nameAm: 'ፋርማሲ',
      description: 'Medical and pharmaceutical products',
    ),
    BusinessType(
      id: 'electronics',
      name: 'Electronics Store',
      nameAm: 'የኤሌክትሮኒክስ ሱቅ',
      description: 'Electronic devices and accessories',
    ),
    BusinessType(
      id: 'clothing',
      name: 'Clothing Store',
      nameAm: 'የልብስ ሱቅ',
      description: 'Fashion and apparel retail',
    ),
    BusinessType(
      id: 'hardware',
      name: 'Hardware Store',
      nameAm: 'የማሽነሪ ሱቅ',
      description: 'Construction materials and tools',
    ),
    BusinessType(
      id: 'wholesale',
      name: 'Wholesale',
      nameAm: 'ጅምላ',
      description: 'Bulk goods distribution',
    ),
    BusinessType(
      id: 'service',
      name: 'Service Provider',
      nameAm: 'አገልግሎት አቅራቢ',
      description: 'Service-based business',
    ),
    BusinessType(
      id: 'other',
      name: 'Other',
      nameAm: 'ሌላ',
      description: 'Other business types',
    ),
  ];
}

class BusinessProfile {
  final int? id;
  final String businessId;
  final String name;
  final String nameAm;
  final String businessType;
  final String phone;
  final String? email;
  final String address;
  final String? city;
  final String? region;
  final String tinNumber;
  final String? vatNumber;
  final String? businessLicense;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final String currency;
  final String? logoPath;
  final String? receiptHeader;
  final String? receiptFooter;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessProfile({
    this.id,
    required this.businessId,
    required this.name,
    required this.nameAm,
    required this.businessType,
    required this.phone,
    this.email,
    required this.address,
    this.city,
    this.region,
    required this.tinNumber,
    this.vatNumber,
    this.businessLicense,
    this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.currency = 'ETB',
    this.logoPath,
    this.receiptHeader,
    this.receiptFooter,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'name_am': nameAm,
      'business_type': businessType,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'region': region,
      'tin_number': tinNumber,
      'vat_number': vatNumber,
      'business_license': businessLicense,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'owner_email': ownerEmail,
      'currency': currency,
      'logo_path': logoPath,
      'receipt_header': receiptHeader,
      'receipt_footer': receiptFooter,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'],
      businessId: map['business_id'],
      name: map['name'],
      nameAm: map['name_am'],
      businessType: map['business_type'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      city: map['city'],
      region: map['region'],
      tinNumber: map['tin_number'],
      vatNumber: map['vat_number'],
      businessLicense: map['business_license'],
      ownerName: map['owner_name'],
      ownerPhone: map['owner_phone'],
      ownerEmail: map['owner_email'],
      currency: map['currency'] ?? 'ETB',
      logoPath: map['logo_path'],
      receiptHeader: map['receipt_header'],
      receiptFooter: map['receipt_footer'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  BusinessProfile copyWith({
    String? name,
    String? nameAm,
    String? businessType,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? region,
    String? tinNumber,
    String? vatNumber,
    String? businessLicense,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? currency,
    String? logoPath,
    String? receiptHeader,
    String? receiptFooter,
    bool? isActive,
  }) {
    return BusinessProfile(
      id: id,
      businessId: businessId,
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      businessType: businessType ?? this.businessType,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      tinNumber: tinNumber ?? this.tinNumber,
      vatNumber: vatNumber ?? this.vatNumber,
      businessLicense: businessLicense ?? this.businessLicense,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      currency: currency ?? this.currency,
      logoPath: logoPath ?? this.logoPath,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
