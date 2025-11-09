import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';

class UserRepository {
  UserRepository(AppDatabase appDatabase); // Remove database parameter

  Future<User?> getUserByPhone(String phone) async {
    final db = await AppDatabase.database; // Use AppDatabase directly
    final result = await db.query(
      'users',
      where: 'phone = ? AND is_active = 1',
      whereArgs: [phone],
    );

    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<User?> getUserById(String id) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<void> createUser(User user) async {
    final db = await AppDatabase.database;
    await db.insert('users', user.toMap());
  }

  Future<void> updateUser(User user) async {
    final db = await AppDatabase.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'user_id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> updateLastLogin(String userId) async {
    final db = await AppDatabase.database;
    await db.update(
      'users',
      {
        'last_login_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await AppDatabase.database;
    final result = await db.query('users', orderBy: 'created_at DESC');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<List<User>> getUsersByBusiness(String businessId) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'users',
      where: 'business_id = ?',
      whereArgs: [businessId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => User.fromMap(map)).toList();
  }
}
