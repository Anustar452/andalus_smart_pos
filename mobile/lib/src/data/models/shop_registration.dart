// src/data/models/shop_registration.dart
class ShopRegistration {
  final String shopName;
  final String shopCategory;
  final String phoneNumber;
  final String city;
  final String country;
  final String businessAddress;
  final String? shopLogo;

  const ShopRegistration({
    required this.shopName,
    required this.shopCategory,
    required this.phoneNumber,
    required this.city,
    required this.country,
    required this.businessAddress,
    this.shopLogo,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_name': shopName,
      'shop_category': shopCategory,
      'phone_number': phoneNumber,
      'city': city,
      'country': country,
      'business_address': businessAddress,
      'shop_logo': shopLogo,
    };
  }
}

class OwnerRegistration {
  final String fullName;
  final String phone;
  final String password;
  final String? email;

  const OwnerRegistration({
    required this.fullName,
    required this.phone,
    required this.password,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'phone': phone,
      'password': password,
      'email': email,
    };
  }
}
