import 'package:andalus_smart_pos/src/data/models/user.dart';

class BusinessRegistration {
  final String businessName;
  final String businessNameAm;
  final String businessType;
  final String phone;
  final String? email; // Make email nullable
  final String address;
  final String city;
  final String region;
  final String tinNumber;
  final String ownerName;
  final String ownerPhone;
  final String? ownerEmail; // Make ownerEmail nullable

  BusinessRegistration({
    required this.businessName,
    required this.businessNameAm,
    required this.businessType,
    required this.phone,
    this.email, // Now nullable
    required this.address,
    required this.city,
    required this.region,
    required this.tinNumber,
    required this.ownerName,
    required this.ownerPhone,
    this.ownerEmail, // Now nullable
  });

  Map<String, dynamic> toMap() {
    return {
      'name': businessName,
      'name_am': businessNameAm,
      'business_type': businessType,
      'phone': phone,
      'email': email, // Can be null
      'address': address,
      'city': city,
      'region': region,
      'tin_number': tinNumber,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'owner_email': ownerEmail, // Can be null
    };
  }
}

class UserRegistration {
  final String name;
  final String phone;
  final String? email; // Make email nullable
  final String password;
  final UserRole role;

  UserRegistration({
    required this.name,
    required this.phone,
    this.email, // Now nullable
    required this.password,
    this.role = UserRole.owner,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email, // Can be null
      'password': password,
      'role': role.name,
    };
  }
}
