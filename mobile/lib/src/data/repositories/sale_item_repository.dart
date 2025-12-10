// data/repositories/sale_item_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/database.dart';
import '../models/sale_item.dart';

class SaleItemRepository {
  Future<Database> get _db async => await AppDatabase.database;

  Future<List<SaleItem>> getSaleItemsBySaleId(int saleId) async {
    final db = await _db;
    try {
      final maps = await db.query(
        'sale_items',
        where: 'sale_id = ?',
        whereArgs: [saleId],
      );
      return maps.map((map) => SaleItem.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching sale items: $e');
      return [];
    }
  }

  Future<List<SaleItem>> getSaleItemsInDateRange(
      DateTime start, DateTime end) async {
    final db = await _db;
    try {
      final maps = await db.query(
        'sale_items',
        where: 'created_at BETWEEN ? AND ?',
        whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      );
      return maps.map((map) => SaleItem.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching sale items in date range: $e');
      return [];
    }
  }

  Future<List<SaleItem>> getAllSaleItems() async {
    final db = await _db;
    try {
      final maps = await db.query('sale_items');
      return maps.map((map) => SaleItem.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching all sale items: $e');
      return [];
    }
  }
}

final saleItemRepositoryProvider = Provider<SaleItemRepository>((ref) {
  return SaleItemRepository();
});
