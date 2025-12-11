// utils/sync_manager.dart
// Utility class for managing data synchronization between local database and remote server.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../data/local/database.dart';
import '../data/remote/api_client.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  final syncManager = SyncManager(ref);
  syncManager.initialize();
  return syncManager;
});

class SyncManager {
  final Ref ref;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncManager(this.ref);

  Future<void> initialize() async {
    // Start periodic sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (!_isSyncing) {
        await syncPendingRecords();
      }
    });
  }

  Future<void> syncPendingRecords() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      await _uploadPendingRecords();
      await _downloadUpdates();
    } catch (e) {
      // Log error but don't throw - sync will retry
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _uploadPendingRecords() async {
    final db = await AppDatabase.database;

    try {
      // Get unsynced sales
      final unsyncedSales = await db.query(
        'sales',
        where: 'is_synced = ?',
        whereArgs: [0],
        limit: 50,
      );

      if (unsyncedSales.isEmpty) return;

      // Get sale items for each unsynced sale
      final salesWithItems = <Map<String, dynamic>>[];

      for (final sale in unsyncedSales) {
        final saleItems = await db.query(
          'sale_items',
          where: 'sale_id = ?',
          whereArgs: [sale['id']],
        );

        salesWithItems.add({
          'sale': sale,
          'items': saleItems,
        });
      }

      // Upload to server (simplified - implement your API call)
      // await _uploadToServer(salesWithItems);

      // Mark as synced
      final batch = db.batch();
      for (final sale in unsyncedSales) {
        batch.update(
          'sales',
          {
            'is_synced': 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [sale['id']],
        );
      }
      await batch.commit();

      print('Successfully synced ${unsyncedSales.length} sales');
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  Future<void> _downloadUpdates() async {
    try {
      final lastSync = await _getLastSyncTimestamp();
      print('Downloading updates since: $lastSync');

      // Implement your download logic here
      // final updates = await ref.read(apiClientProvider).downloadUpdates(lastSync);
      // await _applyServerUpdates(updates);
    } catch (e) {
      print('Download updates error: $e');
    }
  }

  Future<int> _getLastSyncTimestamp() async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery('''
      SELECT MAX(updated_at) as last_sync FROM sales 
      WHERE is_synced = 1
    ''');

    return result.first['last_sync'] as int? ?? 0;
  }

  Future<void> forceSync() async {
    await syncPendingRecords();
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    final db = await AppDatabase.database;

    final pendingResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sales WHERE is_synced = 0
    ''');

    return {
      'pending': pendingResult.first['count'] as int,
      'isSyncing': _isSyncing,
      'lastSync': await _getLastSyncTimestamp(),
    };
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
