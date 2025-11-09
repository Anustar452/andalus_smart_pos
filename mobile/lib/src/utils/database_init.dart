import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

class DatabaseInitializer {
  static Future<void> initializeDefaultData() async {
    final db = await AppDatabase.database;

    // First, create a default business profile if it doesn't exist
    await _createDefaultBusiness(db);

    // Then create default admin user
    await _createDefaultAdminUser(db);
  }

  static Future<void> _createDefaultBusiness(Database db) async {
    final businesses = await db.query('business_profile');
    if (businesses.isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('business_profile', {
        'business_id': 'business_001',
        'name': 'Andalus POS Shop',
        'name_am': 'አንዳሉስ ፖስ ሱቅ',
        'business_type': 'Retail',
        'phone': '+251911223344',
        'email': 'info@andaluspos.com',
        'address': 'Addis Ababa, Ethiopia',
        'city': 'Addis Ababa',
        'region': 'Addis Ababa',
        'tin_number': '0000000000',
        'vat_number': 'VAT000000',
        'business_license': 'LIC001',
        'owner_name': 'Admin User',
        'owner_phone': '+251911223344',
        'owner_email': 'admin@andaluspos.com',
        'currency': 'ETB',
        'logo_path': null,
        'receipt_header':
            'Andalus Smart POS\nMobile-first POS for Ethiopian Shops',
        'receipt_footer': 'Thank you for your business!',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
      print('Default business profile created');
    }
  }

  static Future<void> _createDefaultAdminUser(Database db) async {
    final users = await db.query('users');
    if (users.isEmpty) {
      // Create default admin user with password hash
      final adminUser = User(
        id: 'admin_001',
        name: 'Admin User',
        phone: '+251911223344', // Change this to your admin phone
        email: 'admin@andaluspos.com',
        role: UserRole.owner,
        createdAt: DateTime.now(),
        isActive: true,
        isVerified: true,
        businessId: 'business_001',
        passwordHash: _hashPassword('admin123'), // Set password hash directly
      );

      await db.insert('users', adminUser.toMap());
      print(
          'Default admin user created with phone: ${adminUser.phone} and password: admin123');
    }
  }

  static String _hashPassword(String password) {
    // Simple hashing for demo - in production use more secure hashing
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
