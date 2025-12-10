// lib/src/data/repositories/product_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/database.dart';
import '../models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

class ProductRepository {
  static const String productTable = 'products';

  Future<Database> get _db async => await AppDatabase.database;

  Future<int> createProduct(Product product) async {
    final db = await _db;
    return await db.insert(
      productTable,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await _db;
    await db.update(
      productTable,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<List<Product>> getAllProducts({bool activeOnly = true}) async {
    final db = await _db;
    try {
      final where = activeOnly ? 'WHERE p.is_active = 1' : '';
      final maps = await db.rawQuery('''
        SELECT p.*, c.name as category_name 
        FROM $productTable p 
        LEFT JOIN product_categories c ON p.category_id = c.category_id 
        $where 
        ORDER BY p.name
      ''');
      return maps.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      print('Error in getAllProducts: $e');
      rethrow;
    }
  }

  Future<Product?> getProductById(String productId) async {
    final db = await _db;
    try {
      final maps = await db.rawQuery('''
        SELECT p.*, c.name as category_name 
        FROM $productTable p 
        LEFT JOIN product_categories c ON p.category_id = c.category_id 
        WHERE p.product_id = ?
      ''', [productId]);

      if (maps.isNotEmpty) {
        return Product.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error in getProductById: $e');
      rethrow;
    }
  }

  Future<void> updateStockAfterSale({
    required String productId,
    required int quantitySold,
  }) async {
    final db = await _db;
    try {
      // Get current product
      final product = await getProductById(productId);
      if (product != null && product.trackInventory) {
        final newStock = product.stockQuantity - quantitySold;
        if (newStock >= 0) {
          await db.update(
            productTable,
            {
              'stock_quantity': newStock,
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'product_id = ?',
            whereArgs: [productId],
          );
        } else {
          throw Exception('Insufficient stock for product $productId');
        }
      }
    } catch (e) {
      print('Error in updateStockAfterSale: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final db = await _db;
    try {
      final maps = await db.rawQuery('''
        SELECT p.*, c.name as category_name 
        FROM $productTable p 
        LEFT JOIN product_categories c ON p.category_id = c.category_id 
        WHERE p.category_id = ? AND p.is_active = 1 
        ORDER BY p.name
      ''', [categoryId]);
      return maps.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      print('Error in getProductsByCategory: $e');
      rethrow;
    }
  }

  Future<void> updateStockAfterRefund({
    required String productId,
    required int quantityRefunded,
  }) async {
    final db = await _db;
    try {
      // Get current product
      final product = await getProductById(productId);
      if (product != null && product.trackInventory) {
        final newStock = product.stockQuantity + quantityRefunded;
        await db.update(
          productTable,
          {
            'stock_quantity': newStock,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'product_id = ?',
          whereArgs: [productId],
        );
      }
    } catch (e) {
      print('Error in updateStockAfterRefund: $e');
      rethrow;
    }
  }

  Future<Product?> getProductByIntId(int id) async {
    final db = await _db;
    try {
      final maps = await db.rawQuery('''
        SELECT p.*, c.name as category_name 
        FROM $productTable p 
        LEFT JOIN product_categories c ON p.category_id = c.category_id 
        WHERE p.id = ?
      ''', [id]);

      if (maps.isNotEmpty) {
        return Product.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error in getProductByIntId: $e');
      rethrow;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await _db;
    try {
      final maps = await db.rawQuery('''
        SELECT p.*, c.name as category_name 
        FROM $productTable p 
        LEFT JOIN product_categories c ON p.category_id = c.category_id 
        WHERE (p.name LIKE ? OR p.name_am LIKE ? OR p.barcode LIKE ? OR p.sku LIKE ?) 
        AND p.is_active = 1 
        ORDER BY p.name
      ''', ['%$query%', '%$query%', '%$query%', '%$query%']);
      return maps.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      print('Error in searchProducts: $e');
      rethrow;
    }
  }

  Future<void> updateStockQuantity(int productId, int newQuantity) async {
    final db = await _db;
    try {
      await db.update(
        productTable,
        {
          'stock_quantity': newQuantity,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      print('Error in updateStockQuantity: $e');
      rethrow;
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await _db;
    try {
      final maps = await db.rawQuery('''
        SELECT p.*, c.name as category_name 
        FROM $productTable p 
        LEFT JOIN product_categories c ON p.category_id = c.category_id 
        WHERE p.track_inventory = 1 
        AND p.min_stock_level IS NOT NULL 
        AND p.stock_quantity <= p.min_stock_level 
        AND p.is_active = 1 
        ORDER BY p.stock_quantity ASC
      ''');
      return maps.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      print('Error in getLowStockProducts: $e');
      rethrow;
    }
  }

  Future<List<Product>> getActiveProducts() async {
    final db = await _db;
    try {
      final maps = await db.rawQuery('''
        SELECT p.*, c.name as category_name 
        FROM $productTable p 
        LEFT JOIN product_categories c ON p.category_id = c.category_id 
        WHERE p.is_active = 1 
        ORDER BY p.name
      ''');
      return maps.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      print('Error in getActiveProducts: $e');
      rethrow;
    }
  }

  Future<void> deactivateProduct(int productId) async {
    final db = await _db;
    try {
      await db.update(
        productTable,
        {
          'is_active': 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      print('Error in deactivateProduct: $e');
      rethrow;
    }
  }

  Future<void> activateProduct(int productId) async {
    final db = await _db;
    try {
      await db.update(
        productTable,
        {
          'is_active': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      print('Error in activateProduct: $e');
      rethrow;
    }
  }

  Future<void> createSampleProducts(ProductRepository productRepo) async {
    final sampleProducts = [
      Product(
        id: 1,
        name: 'Sample Product 1',
        sku: 'SP001',
        barcode: '1234567890123',
        categoryId: 'cat1',
        price: 9.99,
        stockQuantity: 100,
        isActive: true,
        trackInventory: true,
        productId: '',
        nameAm: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 2,
        name: 'Sample Product 2',
        sku: 'SP002',
        barcode: '1234567890124',
        categoryId: 'cat2',
        price: 19.99,
        stockQuantity: 50,
        isActive: true,
        trackInventory: true,
        productId: '',
        nameAm: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var product in sampleProducts) {
      await productRepo.createProduct(product);
    }
  }
}
