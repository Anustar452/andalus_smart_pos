import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/data/models/otp.dart';

class OTPRepository {
  OTPRepository(); // Remove database parameter

  Future<void> createOTP(OTP otp) async {
    final db = await AppDatabase.database;

    // Clean expired OTPs for this phone
    await db.delete(
      'otps',
      where: 'phone = ? AND expires_at < ?',
      whereArgs: [otp.phone, DateTime.now().millisecondsSinceEpoch],
    );

    await db.insert('otps', otp.toMap());
  }

  Future<OTP?> getValidOTP(String phone, String code, String type) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'otps',
      where:
          'phone = ? AND code = ? AND type = ? AND is_used = 0 AND expires_at > ?',
      whereArgs: [phone, code, type, DateTime.now().millisecondsSinceEpoch],
    );

    if (result.isEmpty) return null;
    return OTP.fromMap(result.first);
  }

  Future<void> markOTPAsUsed(String otpId) async {
    final db = await AppDatabase.database;
    await db.update(
      'otps',
      {'is_used': 1},
      where: 'otp_id = ?',
      whereArgs: [otpId],
    );
  }

  Future<void> cleanExpiredOTPs() async {
    final db = await AppDatabase.database;
    await db.delete(
      'otps',
      where: 'expires_at < ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch],
    );
  }
}
