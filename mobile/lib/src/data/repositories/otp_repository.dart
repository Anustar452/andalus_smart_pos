// lib/src/data/repositories/otp_repository.dart
import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/data/models/otp.dart';

class OTPRepository {
  OTPRepository();

  Future<void> createOTP(OTP otp) async {
    final db = await AppDatabase.database;

    try {
      // Clean expired OTPs for this phone
      await db.delete(
        'otps',
        where: 'phone = ? AND expires_at < ?',
        whereArgs: [otp.phone, DateTime.now().millisecondsSinceEpoch],
      );

      final result = await db.insert('otps', otp.toMap());
      print('✅ OTP inserted successfully. Row ID: $result');
      print(
          '📝 OTP Details - Phone: ${otp.phone}, Code: ${otp.code}, Expires: ${otp.expiresAt}');
    } catch (e) {
      print('❌ Error creating OTP: $e');
      rethrow;
    }
  }

  Future<OTP?> getValidOTP(String phone, String code, String type) async {
    final db = await AppDatabase.database;

    try {
      print('🔍 Searching for OTP - Phone: $phone, Code: $code, Type: $type');

      final result = await db.query(
        'otps',
        where:
            'phone = ? AND code = ? AND type = ? AND is_used = 0 AND expires_at > ?',
        whereArgs: [phone, code, type, DateTime.now().millisecondsSinceEpoch],
      );

      print('📊 OTP query found ${result.length} records');

      if (result.isNotEmpty) {
        for (var row in result) {
          print('📄 OTP Record: ${row.toString()}');
        }

        final otp = OTP.fromMap(result.first);
        print('✅ Valid OTP found: ${otp.code} for ${otp.phone}');
        print(
            '⏰ OTP expires at: ${otp.expiresAt}, Current time: ${DateTime.now()}');
        print('🔑 OTP is used: ${otp.isUsed}, Is valid: ${otp.isValid}');

        return otp;
      } else {
        print('❌ No valid OTP found');

        // Let's check what's actually in the database
        final allOtps = await db.query(
          'otps',
          where: 'phone = ?',
          whereArgs: [phone],
        );

        print('📋 All OTPs for $phone: ${allOtps.length} records');
        for (var otp in allOtps) {
          print(
              '📄 OTP: ${otp['code']}, Used: ${otp['is_used']}, Expires: ${DateTime.fromMillisecondsSinceEpoch(otp['expires_at'] as int)}');
        }

        return null;
      }
    } catch (e) {
      print('❌ Error getting OTP: $e');
      return null;
    }
  }

  Future<List<OTP>> getAllOTPsForPhone(String phone) async {
    final db = await AppDatabase.database;
    try {
      final result = await db.query(
        'otps',
        where: 'phone = ?',
        whereArgs: [phone],
        orderBy: 'created_at DESC',
      );

      // Convert Map to OTP objects
      return result.map((map) => OTP.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error getting OTPs for phone: $e');
      return [];
    }
  }

  Future<void> markOTPAsUsed(String otpId) async {
    final db = await AppDatabase.database;

    try {
      final result = await db.update(
        'otps',
        {'is_used': 1},
        where: 'otp_id = ?',
        whereArgs: [otpId],
      );

      print('✅ OTP marked as used: $otpId, rows affected: $result');
    } catch (e) {
      print('❌ Error marking OTP as used: $e');
      rethrow;
    }
  }

  Future<void> cleanExpiredOTPs() async {
    final db = await AppDatabase.database;
    final deleted = await db.delete(
      'otps',
      where: 'expires_at < ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch],
    );
    print('🧹 Cleaned $deleted expired OTPs');
  }
}
