// lib/src/data/repositories/sale_repository.dart
import 'package:flutter/src/material/date.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/database.dart'; // Import AppDatabase
import '../models/sale.dart';
import '../models/sale_item.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository();
});

class SaleRepository {
  static const String saleTable = 'sales';
  static const String saleItemTable = 'sale_items';

  Future<Database> get _db async => await AppDatabase.database;

// Add this method to your SaleRepository class
  Future<void> createSampleSales() async {
    final db = await _db;

    // Clear existing sample data to avoid duplicates
    await db.delete('sales', where: 'sale_id LIKE ?', whereArgs: ['SAMPLE-%']);

    final sampleSales = [
      {
        'sale_id': 'SAMPLE-${DateTime.now().millisecondsSinceEpoch}',
        'total_amount': 250.0,
        'final_amount': 250.0,
        'payment_method': 'cash',
        'user_id': 1,
        'shop_id': 1,
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 1))
            .millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'sale_id': 'SAMPLE-${DateTime.now().millisecondsSinceEpoch + 1}',
        'total_amount': 150.0,
        'final_amount': 150.0,
        'payment_method': 'telebirr',
        'user_id': 1,
        'shop_id': 1,
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 2))
            .millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'sale_id': 'SAMPLE-${DateTime.now().millisecondsSinceEpoch + 2}',
        'total_amount': 75.0,
        'final_amount': 75.0,
        'payment_method': 'card',
        'user_id': 1,
        'shop_id': 1,
        'created_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'sale_id': 'SAMPLE-${DateTime.now().millisecondsSinceEpoch + 3}',
        'total_amount': 320.0,
        'final_amount': 320.0,
        'payment_method': 'cash',
        'user_id': 1,
        'shop_id': 1,
        'created_at': DateTime.now()
            .subtract(const Duration(days: 2))
            .millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'sale_id': 'SAMPLE-${DateTime.now().millisecondsSinceEpoch + 4}',
        'total_amount': 95.0,
        'final_amount': 95.0,
        'payment_method': 'telebirr',
        'user_id': 1,
        'shop_id': 1,
        'created_at': DateTime.now()
            .subtract(const Duration(days: 3))
            .millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    final batch = db.batch();

    for (final saleData in sampleSales) {
      batch.insert('sales', saleData);
    }

    await batch.commit();
    print('Sample sales data created successfully');
  }

  // Create a new sale with items
  Future<int> createSale(Sale sale, List<SaleItem> items) async {
    final db = await _db;

    return await db.transaction((txn) async {
      // Insert sale
      final saleId = await txn.insert(
        saleTable,
        sale.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert sale items
      for (final item in items) {
        await txn.insert(
          saleItemTable,
          item.copyWith(saleId: saleId as String).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return saleId;
    });
  }

  // Get all sales with pagination
  Future<List<Sale>> getAllSales({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _db;
    final maps = await db.query(
      saleTable,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => Sale.fromMap(map)).toList();
  }

  // Get sale by ID with items
  Future<SaleWithItems?> getSaleById(int id) async {
    final db = await _db;

    final saleMaps = await db.query(
      saleTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (saleMaps.isEmpty) return null;

    final sale = Sale.fromMap(saleMaps.first);
    final itemMaps = await db.query(
      saleItemTable,
      where: 'sale_id = ?',
      whereArgs: [id],
    );

    final items = itemMaps.map((map) => SaleItem.fromMap(map)).toList();

    return SaleWithItems(sale: sale, items: items);
  }

  // Get today's sales
  Future<List<Sale>> getTodaysSales() async {
    final db = await _db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final maps = await db.query(
      saleTable,
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Sale.fromMap(map)).toList();
  }

  // Get sales summary for dashboard
  Future<SalesSummary> getSalesSummary(
      {DateTimeRange<DateTime>? dateRange}) async {
    final db = await _db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    try {
      final todayResult = await db.rawQuery('''
      SELECT COUNT(*) as count, COALESCE(SUM(final_amount), 0) as total 
      FROM sales WHERE created_at BETWEEN ? AND ?
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);

      final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as count, COALESCE(SUM(final_amount), 0) as total FROM sales
    ''');

      final weekResult = await db.rawQuery('''
      SELECT COUNT(*) as count, COALESCE(SUM(final_amount), 0) as total 
      FROM sales WHERE created_at >= ?
    ''', [startOfWeek.millisecondsSinceEpoch]);

      return SalesSummary.fromDatabase(
        todayResult.first,
        totalResult.first,
        weekResult.first,
      );
    } catch (e) {
      print('Error in getSalesSummary: $e');
      return SalesSummary(
        todaysSales: 0.0,
        todaysOrders: 0,
        totalSales: 0.0,
        totalOrders: 0,
        weeklySales: 0.0,
        weeklyOrders: 0,
      );
    }
  }

  Future<List<Sale>> searchSales({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentMethod,
    String? status,
    int? customerId,
  }) async {
    final db = await _db;

    List<String> whereConditions = [];
    List<Object?> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereConditions.add('(sale_id LIKE ? OR customer_name LIKE ?)');
      whereArgs.addAll(['%$query%', '%$query%']);
    }

    if (startDate != null) {
      whereConditions.add('created_at >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereConditions.add('created_at <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    if (paymentMethod != null) {
      whereConditions.add('payment_method = ?');
      whereArgs.add(paymentMethod);
    }

    if (status != null) {
      whereConditions.add('sale_status = ?');
      whereArgs.add(status);
    }

    if (customerId != null) {
      whereConditions.add('customer_id = ?');
      whereArgs.add(customerId);
    }

    final whereClause = whereConditions.isNotEmpty
        ? 'WHERE ${whereConditions.join(' AND ')}'
        : '';

    final maps = await db.rawQuery('''
      SELECT * FROM $saleTable 
      $whereClause 
      ORDER BY created_at DESC 
      LIMIT 100
    ''', whereArgs);

    return maps.map((map) => Sale.fromMap(map)).toList();
  }

  Future<Sale> refundSale({
    required int saleId,
    required String reason,
    bool fullRefund = true,
    List<String>? itemIds,
    Map<String, int>? partialQuantities,
  }) async {
    final db = await _db;

    return await db.transaction((txn) async {
      // Get original sale
      final saleMaps = await txn.query(
        saleTable,
        where: 'id = ?',
        whereArgs: [saleId],
      );

      if (saleMaps.isEmpty) {
        throw Exception('Sale not found');
      }

      final originalSale = Sale.fromMap(saleMaps.first);

      // Create refund sale
      final refundSale = Sale(
        saleId: 'REFUND_${originalSale.saleId}',
        localId: 'REFUND_LOCAL_${DateTime.now().millisecondsSinceEpoch}',
        customerId: originalSale.customerId,
        customerName: originalSale.customerName,
        totalAmount: originalSale.totalAmount,
        finalAmount: -originalSale.finalAmount, // Negative amount for refund
        taxAmount: originalSale.taxAmount,
        discountAmount: originalSale.discountAmount,
        paymentMethod: 'refund',
        paymentReference: 'REFUND_${originalSale.saleId}',
        paymentStatus: 'refunded',
        saleStatus: 'refunded',
        userId: originalSale.userId,
        userName: originalSale.userName,
        shopId: originalSale.shopId,
        isSynced: false,
        syncAttempts: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: 'Refund: $reason',
        isRefunded: false, // This is the refund record itself
        refundReason: reason,
        refundedAt: DateTime.now(),
      );

      // Save refund sale
      final refundSaleId = await txn.insert(
        saleTable,
        refundSale.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Update original sale status
      await txn.update(
        saleTable,
        {
          'sale_status': 'refunded',
          'payment_status': 'refunded',
          'is_refunded': 1,
          'refund_reason': reason,
          'refunded_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [saleId],
      );

      return refundSale.copyWith(id: refundSaleId);
    });
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await _db;
    final maps = await db.query(
      saleItemTable,
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );

    return maps.map((map) => SaleItem.fromMap(map)).toList();
  }

  Future<Sale?> getSimpleSaleById(int id) async {
    final db = await _db;
    final saleMaps = await db.query(
      saleTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (saleMaps.isEmpty) return null;
    return Sale.fromMap(saleMaps.first);
  }

  // Get unsynced sales for synchronization
  Future<List<Sale>> getUnsyncedSales() async {
    final db = await _db;
    final maps = await db.query(
      saleTable,
      where: 'is_synced = 0',
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => Sale.fromMap(map)).toList();
  }

// Add this method to SaleRepository class for testing
  Future<void> addSampleSales() async {
    final sampleSales = [
      Sale(
        localId: 'sample_1',
        totalAmount: 150.0,
        finalAmount: 150.0,
        paymentMethod: 'cash',
        userId: 1,
        shopId: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        saleId: '',
      ),
      Sale(
        localId: 'sample_2',
        totalAmount: 75.0,
        finalAmount: 75.0,
        paymentMethod: 'telebirr',
        userId: 1,
        shopId: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        saleId: '',
      ),
    ];

    for (final sale in sampleSales) {
      await createSale(sale, [
        SaleItem(
          saleId: '0', // Will be replaced with actual sale ID
          productId: '1',
          productName: 'Coca Cola',
          quantity: 2,
          unitPrice: 25.0,
          totalPrice: 50.0,
          createdAt: sale.createdAt,
        ),
      ]);
    }
  }

  // Mark sale as synced
  Future<void> markAsSynced(int saleId) async {
    final db = await _db;
    await db.update(
      saleTable,
      {
        'is_synced': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }
}

// Helper class to combine sale with its items
class SaleWithItems {
  final Sale sale;
  final List<SaleItem> items;

  SaleWithItems({required this.sale, required this.items});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
}

extension SaleRefundExtension on Sale {
  bool get canBeRefunded {
    if (isRefunded) return false;
    if (saleStatus != 'completed') return false;
    if (paymentStatus != 'completed') return false;

    // 30-day refund window
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return createdAt.isAfter(thirtyDaysAgo);
  }
}

// Add this extension to SaleWithItems class
extension SaleWithItemsRefundExtension on SaleWithItems {
  bool get canBeRefunded => sale.canBeRefunded;
}

// Sales summary for dashboard
class SalesSummary {
  final double todaysSales;
  final int todaysOrders;
  final double totalSales;
  final int totalOrders;
  final double weeklySales;
  final int weeklyOrders;

  SalesSummary({
    required this.todaysSales,
    required this.todaysOrders,
    required this.totalSales,
    required this.totalOrders,
    required this.weeklySales,
    required this.weeklyOrders,
  });
  factory SalesSummary.fromDatabase(Map<String, dynamic> todayResult,
      Map<String, dynamic> totalResult, Map<String, dynamic> weekResult) {
    return SalesSummary(
      todaysSales: (todayResult['total'] as num?)?.toDouble() ?? 0.0,
      todaysOrders: (todayResult['count'] as num?)?.toInt() ?? 0,
      totalSales: (totalResult['total'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (totalResult['count'] as num?)?.toInt() ?? 0,
      weeklySales: (weekResult['total'] as num?)?.toDouble() ?? 0.0,
      weeklyOrders: (weekResult['count'] as num?)?.toInt() ?? 0,
    );
  }
}

// Add method to create sample sales data for testing
Future<void> createSampleSales() async {
  final sampleSales = [
    Sale(
      saleId: 'SALE-${DateTime.now().millisecondsSinceEpoch}',
      totalAmount: 250.0,
      finalAmount: 250.0,
      paymentMethod: 'cash',
      userId: 1,
      shopId: 1,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      localId: '',
    ),
    Sale(
      saleId: 'SALE-${DateTime.now().millisecondsSinceEpoch + 1}',
      totalAmount: 150.0,
      finalAmount: 150.0,
      paymentMethod: 'telebirr',
      userId: 1,
      shopId: 1,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      localId: '',
    ),
    Sale(
      saleId: 'SALE-${DateTime.now().millisecondsSinceEpoch + 2}',
      totalAmount: 75.0,
      finalAmount: 75.0,
      paymentMethod: 'card',
      userId: 1,
      shopId: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      localId: '',
    ),
  ];

  for (final sale in sampleSales) {
    await createSale(sale, [
      SaleItem(
        saleId: '0', // Will be replaced with actual sale ID
        productId: '1',
        productName: 'Sample Product',
        quantity: 2,
        unitPrice: 25.0,
        totalPrice: 50.0,
        createdAt: sale.createdAt,
      ),
    ]);
  }
}

Future<void> createSale(Sale sale, List<SaleItem> items) async {
  final repository = SaleRepository();
  await repository.createSale(sale, items);
}
