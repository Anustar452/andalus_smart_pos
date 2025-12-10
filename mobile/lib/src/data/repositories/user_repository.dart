//src/data/repositories/user_repository.dart
import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';

class UserRepository {
  UserRepository();

  Future<User?> getUserByPhone(String phone) async {
    final db = await AppDatabase.database;

    try {
      final result = await db.query(
        'users',
        where: 'phone = ?',
        whereArgs: [phone],
      );

      print(
          'User query result: ${result.length} users found for phone: $phone');

      if (result.isEmpty) return null;

      final user = User.fromMap(result.first);
      print('User found: ${user.name} (${user.role})');

      return user;
    } catch (e) {
      print('Error getting user by phone: $e');
      return null;
    }
  }

  Future<User?> getUserById(String userId) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
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

    print('Last login updated for user: $userId');
  }
}

Future<void> deleteUser(String userId) async {
  final db = await AppDatabase.database;
  await db.delete(
    'users',
    where: 'user_id = ?',
    whereArgs: [userId],
  );
}
