import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:andalus_smart_pos/src/data/models/product.dart';
import 'package:andalus_smart_pos/src/data/repositories/product_repository.dart';
import 'package:andalus_smart_pos/src/data/local/database.dart';

void main() {
  late ProductRepository repository;
  late Database database;

  setUpAll(() {
    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create in-memory database for testing
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    // Initialize schema
    await AppDatabase._onCreate(database, 1);

    repository = ProductRepository();
    // Override the database getter for testing
    // Note: This requires making the _db getter protected or using dependency injection
  });

  tearDown(() async {
    await database.close();
  });

  group('ProductRepository', () {
    test('insert and retrieve product', () async {
      final product = Product(
        localId: 'test_001',
        name: 'Test Product',
        nameAm: 'ፈተና ምርት',
        barcode: '123456789',
        price: 100.0,
        stockQuantity: 50,
        category: 'Test Category',
        categoryAm: 'ፈተና ምድብ',
        unit: 'pcs',
        unitAm: 'ቁራጭ',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await repository.insertProduct(product);
      expect(id, greaterThan(0));

      final retrieved = await repository.getProductById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Test Product'));
      expect(retrieved.nameAm, equals('ፈተና ምርት'));
      expect(retrieved.price, equals(100.0));
    });

    test('update product stock', () async {
      final product = Product(
        localId: 'test_002',
        name: 'Stock Product',
        nameAm: 'ክምችት ምርት',
        barcode: '987654321',
        price: 50.0,
        stockQuantity: 100,
        category: 'Test Category',
        categoryAm: 'ፈተና ምድብ',
        unit: 'pcs',
        unitAm: 'ቁራጭ',
      );

      final id = await repository.insertProduct(product);
      await repository.updateStock(id, 75);

      final updated = await repository.getProductById(id);
      expect(updated!.stockQuantity, equals(75));
    });

    test('search products by name', () async {
      // Insert test products
      await repository.insertProduct(
        Product(
          localId: 'search_001',
          name: 'Coca Cola',
          nameAm: 'ኮካ ኮላ',
          barcode: '111111',
          price: 25.0,
          stockQuantity: 100,
          category: 'Beverages',
          categoryAm: 'መጠጥ',
          unit: 'can',
          unitAm: 'ቆጣሪ',
        ),
      );

      await repository.insertProduct(
        Product(
          localId: 'search_002',
          name: 'Pepsi Cola',
          nameAm: 'ፔፕሲ ኮላ',
          barcode: '222222',
          price: 24.0,
          stockQuantity: 80,
          category: 'Beverages',
          categoryAm: 'መጠጥ',
          unit: 'can',
          unitAm: 'ቆጣሪ',
        ),
      );

      final results = await repository.searchProducts('cola');
      expect(results.length, equals(2));
      expect(results.any((p) => p.name.contains('Coca')), isTrue);
      expect(results.any((p) => p.name.contains('Pepsi')), isTrue);
    });

    test('get product by barcode', () async {
      const barcode = 'TEST123456';

      await repository.insertProduct(
        Product(
          localId: 'barcode_001',
          name: 'Barcode Product',
          nameAm: 'ባርኮድ ምርት',
          barcode: barcode,
          price: 99.0,
          stockQuantity: 10,
          category: 'Test',
          categoryAm: 'ፈተና',
          unit: 'pcs',
          unitAm: 'ቁራጭ',
        ),
      );

      final product = await repository.getProductByBarcode(barcode);
      expect(product, isNotNull);
      expect(product!.barcode, equals(barcode));
      expect(product.name, equals('Barcode Product'));
    });

    test('soft delete product', () async {
      final product = Product(
        localId: 'delete_001',
        name: 'Delete Product',
        nameAm: 'ለመሰረዝ ምርት',
        barcode: 'DEL123',
        price: 10.0,
        stockQuantity: 5,
        category: 'Test',
        categoryAm: 'ፈተና',
        unit: 'pcs',
        unitAm: 'ቁራጭ',
      );

      final id = await repository.insertProduct(product);
      await repository.deleteProduct(id);

      final deleted = await repository.getProductById(id);
      expect(deleted, isNotNull);
      expect(deleted!.isActive, isFalse);
    });
  });
}
