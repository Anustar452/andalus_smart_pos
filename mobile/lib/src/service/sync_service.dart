// lib/src/services/sync_service.dart
// Service for synchronizing local data with the remote server.
import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/database.dart';
import '../data/models/sale.dart';
import '../data/models/product.dart';
import '../data/models/customer.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final service = SyncService();
      await service.syncAllData();
      return Future.value(true);
    } catch (e) {
      print('Background sync error: $e');
      return Future.value(false);
    }
  });
}

class SyncService {
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _syncStatusKey = 'sync_status';
  static const Duration _syncInterval = Duration(minutes: 15);
  static const int _maxRetries = 3;

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register periodic sync
    await Workmanager().registerPeriodicTask(
      'pos_sync',
      'pos_sync_task',
      frequency: _syncInterval,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresStorageNotLow: false,
      ),
      initialDelay: const Duration(seconds: 10),
    );
  }

  Future<SyncResult> syncAllData() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      print('No internet connection for sync');
      return SyncResult.noConnection();
    }

    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Skip if synced recently
    if (now - lastSync < _syncInterval.inMilliseconds ~/ 2) {
      return SyncResult.skipped();
    }

    try {
      await prefs.setString(_syncStatusKey, 'syncing');

      // Sync in order of importance
      final salesResult = await _syncSales();
      final productsResult = await _syncProducts();
      final customersResult = await _syncCustomers();

      await prefs.setInt(_lastSyncKey, now);
      await prefs.setString(_syncStatusKey, 'success');

      return SyncResult.success(
        syncedSales: salesResult.syncedCount,
        syncedProducts: productsResult.syncedCount,
        syncedCustomers: customersResult.syncedCount,
      );
    } catch (e, stackTrace) {
      await prefs.setString(_syncStatusKey, 'failed');

      // Log error
      print('Sync error: $e');
      print('Stack trace: $stackTrace');

      return SyncResult.failed(e.toString());
    }
  }

  Future<SyncBatchResult> _syncSales() async {
    final db = await AppDatabase.database;
    final unsyncedSales = await db.query(
      'sales',
      where: 'is_synced = 0 AND sync_attempts < ?',
      whereArgs: [_maxRetries],
    );

    int syncedCount = 0;
    int failedCount = 0;

    for (final saleData in unsyncedSales) {
      try {
        final sale = Sale.fromMap(saleData);

        // Validate sale before syncing
        if (!sale.isValid() || !sale.isTotalValid) {
          await _markSaleAsInvalid(saleData['id'] as int);
          failedCount++;
          continue;
        }

        // Get sale items
        final items = await db.query(
          'sale_items',
          where: 'sale_id = ?',
          whereArgs: [saleData['sale_id']],
        );

        // Upload to server (simulate API call)
        // await _api.uploadSale(sale, items);
        await Future.delayed(const Duration(milliseconds: 100)); // Simulate API

        // Mark as synced
        await db.update(
          'sales',
          {
            'is_synced': 1,
            'synced_at': DateTime.now().millisecondsSinceEpoch,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [saleData['id']],
        );

        // Mark items as synced
        for (final item in items) {
          await db.update(
            'sale_items',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }

        syncedCount++;
      } catch (e) {
        failedCount++;

        // Increment sync attempts
        await db.update(
          'sales',
          {
            'sync_attempts': (saleData['sync_attempts'] as int? ?? 0) + 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [saleData['id']],
        );

        // If max retries reached, move to failed queue
        if ((saleData['sync_attempts'] as int? ?? 0) + 1 >= _maxRetries) {
          await _moveToFailedQueue('sales', saleData);
        }
      }
    }

    return SyncBatchResult(
      type: 'sales',
      syncedCount: syncedCount,
      failedCount: failedCount,
    );
  }

  Future<SyncBatchResult> _syncProducts() async {
    final db = await AppDatabase.database;
    final unsyncedProducts = await db.query(
      'products',
      where: 'is_synced = 0 AND sync_attempts < ?',
      whereArgs: [_maxRetries],
    );

    int syncedCount = 0;
    int failedCount = 0;

    for (final productData in unsyncedProducts) {
      try {
        final product = Product.fromMap(productData);

        // Validate product
        if (!product.verifyChecksum()) {
          await _markProductAsInvalid(productData['id'] as int);
          failedCount++;
          continue;
        }

        // Upload to server
        // await _api.uploadProduct(product);
        await Future.delayed(const Duration(milliseconds: 50));

        // Mark as synced
        await db.update(
          'products',
          {
            'is_synced': 1,
            'synced_at': DateTime.now().millisecondsSinceEpoch,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [productData['id']],
        );

        syncedCount++;
      } catch (e) {
        failedCount++;

        await db.update(
          'products',
          {
            'sync_attempts': (productData['sync_attempts'] as int? ?? 0) + 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [productData['id']],
        );
      }
    }

    return SyncBatchResult(
      type: 'products',
      syncedCount: syncedCount,
      failedCount: failedCount,
    );
  }

  Future<SyncBatchResult> _syncCustomers() async {
    final db = await AppDatabase.database;
    final unsyncedCustomers = await db.query(
      'customers',
      where: 'is_synced = 0 AND sync_attempts < ?',
      whereArgs: [_maxRetries],
    );

    int syncedCount = 0;
    int failedCount = 0;

    for (final customerData in unsyncedCustomers) {
      try {
        // Upload to server
        // await _api.uploadCustomer(customerData);
        await Future.delayed(const Duration(milliseconds: 50));

        // Mark as synced
        await db.update(
          'customers',
          {
            'is_synced': 1,
            'synced_at': DateTime.now().millisecondsSinceEpoch,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [customerData['id']],
        );

        syncedCount++;
      } catch (e) {
        failedCount++;

        await db.update(
          'customers',
          {
            'sync_attempts': (customerData['sync_attempts'] as int? ?? 0) + 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [customerData['id']],
        );
      }
    }

    return SyncBatchResult(
      type: 'customers',
      syncedCount: syncedCount,
      failedCount: failedCount,
    );
  }

  Future<void> _markSaleAsInvalid(int saleId) async {
    final db = await AppDatabase.database;
    await db.update(
      'sales',
      {
        'is_synced': 2, // 2 = invalid
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }

  Future<void> _markProductAsInvalid(int productId) async {
    final db = await AppDatabase.database;
    await db.update(
      'products',
      {
        'is_synced': 2, // 2 = invalid
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> _moveToFailedQueue(
      String type, Map<String, dynamic> data) async {
    final db = await AppDatabase.database;
    await db.insert('failed_syncs', {
      'type': type,
      'data': jsonEncode(data),
      'error': 'Max retries reached',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // === SYNC STATUS ===
  Future<SyncStatus> getSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString(_syncStatusKey) ?? 'idle';
    final lastSync = prefs.getInt(_lastSyncKey) ?? 0;

    return SyncStatus(
      status: status,
      lastSync:
          lastSync == 0 ? null : DateTime.fromMillisecondsSinceEpoch(lastSync),
    );
  }

  Future<void> forceSync() async {
    await syncAllData();
  }

  Future<List<Map<String, dynamic>>> getFailedSyncs() async {
    final db = await AppDatabase.database;
    return await db.query('failed_syncs', orderBy: 'created_at DESC');
  }

  Future<void> retryFailedSync(int id) async {
    final db = await AppDatabase.database;
    final failed =
        await db.query('failed_syncs', where: 'id = ?', whereArgs: [id]);

    if (failed.isNotEmpty) {
      final data = jsonDecode(failed.first['data'] as String);
      final type = failed.first['type'] as String;

      // Retry logic based on type
      // ...

      // Remove from failed queue
      await db.delete('failed_syncs', where: 'id = ?', whereArgs: [id]);
    }
  }
}

// === DATA CLASSES ===
class SyncResult {
  final bool success;
  final String? error;
  final int syncedSales;
  final int syncedProducts;
  final int syncedCustomers;
  final bool hasConnection;
  final bool wasSkipped;

  const SyncResult({
    required this.success,
    this.error,
    this.syncedSales = 0,
    this.syncedProducts = 0,
    this.syncedCustomers = 0,
    this.hasConnection = true,
    this.wasSkipped = false,
  });

  factory SyncResult.success({
    int syncedSales = 0,
    int syncedProducts = 0,
    int syncedCustomers = 0,
  }) {
    return SyncResult(
      success: true,
      syncedSales: syncedSales,
      syncedProducts: syncedProducts,
      syncedCustomers: syncedCustomers,
    );
  }

  factory SyncResult.failed(String error) {
    return SyncResult(success: false, error: error);
  }

  factory SyncResult.noConnection() {
    return SyncResult(success: false, hasConnection: false);
  }

  factory SyncResult.skipped() {
    return SyncResult(success: true, wasSkipped: true);
  }
}

class SyncBatchResult {
  final String type;
  final int syncedCount;
  final int failedCount;

  const SyncBatchResult({
    required this.type,
    required this.syncedCount,
    required this.failedCount,
  });
}

class SyncStatus {
  final String status; // 'idle', 'syncing', 'success', 'failed'
  final DateTime? lastSync;

  const SyncStatus({
    required this.status,
    this.lastSync,
  });

  bool get isSyncing => status == 'syncing';
  bool get hasSynced => lastSync != null;
}

// Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});
