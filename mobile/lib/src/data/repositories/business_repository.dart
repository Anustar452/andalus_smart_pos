import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/database.dart';
import '../models/business.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository();
});

class BusinessRepository {
  static const String businessTable = 'business_profile';

  Future<Database> get _db async => await AppDatabase.database;

  Future<void> saveBusinessProfile(BusinessProfile business) async {
    final db = await _db;
    await db.insert(
      businessTable,
      business.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BusinessProfile?> getBusinessProfile() async {
    final db = await _db;
    final maps = await db.query(businessTable, limit: 1);
    if (maps.isNotEmpty) {
      return BusinessProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateBusinessProfile(BusinessProfile business) async {
    final db = await _db;
    await db.update(
      businessTable,
      business.toMap(),
      where: 'id = ?',
      whereArgs: [business.id],
    );
  }

  Future<bool> hasBusinessProfile() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $businessTable'));
    return count != null && count > 0;
  }
}
