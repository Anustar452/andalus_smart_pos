// mobile/lib/src/data/repositories/category_repository.dart
// Repository for managing product categories in the local database.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/database.dart';
import '../models/category.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

class CategoryRepository {
  static const String categoryTable = 'product_categories';

  Future<Database> get _db async => await AppDatabase.database;

  Future<int> createCategory(ProductCategory category) async {
    final db = await _db;
    return await db.insert(
      categoryTable,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(ProductCategory category) async {
    final db = await _db;
    await db.update(
      categoryTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<List<ProductCategory>> getAllCategories(
      {bool activeOnly = true}) async {
    final db = await _db;
    final where = activeOnly ? 'WHERE is_active = 1' : '';
    final maps = await db.rawQuery('''
    SELECT * FROM $categoryTable $where ORDER BY sort_order, name
  ''');
    return maps.map((map) => ProductCategory.fromMap(map)).toList();
  }

  Future<ProductCategory?> getCategoryById(int id) async {
    final db = await _db;
    final maps = await db.query(
      categoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ProductCategory.fromMap(maps.first);
    }
    return null;
  }

  Future<void> deleteCategory(int id) async {
    final db = await _db;
    await db.delete(
      categoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
