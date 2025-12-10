//src/data/models/otp.dart
class OTP {
  final String id;
  final String phone;
  final String code;
  final String type; // 'login', 'reset_password', 'verify_phone'
  final bool isUsed;
  final DateTime expiresAt;
  final DateTime createdAt;

  OTP({
    required this.id,
    required this.phone,
    required this.code,
    required this.type,
    this.isUsed = false,
    required this.expiresAt,
    required this.createdAt,
  });

  factory OTP.create({
    required String phone,
    required String type,
    int validityMinutes = 10,
  }) {
    final now = DateTime.now();
    return OTP(
      id: 'otp_${now.millisecondsSinceEpoch}',
      phone: phone,
      code: _generateOTP(),
      type: type,
      expiresAt: now.add(Duration(minutes: validityMinutes)),
      createdAt: now,
    );
  }

  static String _generateOTP() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString().substring(0, 6);
  }

  Map<String, dynamic> toMap() {
    return {
      'otp_id': id,
      'phone': phone,
      'code': code,
      'type': type,
      'is_used': isUsed ? 1 : 0,
      'expires_at': expiresAt.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory OTP.fromMap(Map<String, dynamic> map) {
    return OTP(
      id: map['otp_id'],
      phone: map['phone'],
      code: map['code'],
      type: map['type'],
      isUsed: map['is_used'] == 1,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expires_at']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  bool get isValid => !isUsed && DateTime.now().isBefore(expiresAt);

  OTP markAsUsed() {
    return OTP(
      id: id,
      phone: phone,
      code: code,
      type: type,
      isUsed: true,
      expiresAt: expiresAt,
      createdAt: createdAt,
    );
  }
}
