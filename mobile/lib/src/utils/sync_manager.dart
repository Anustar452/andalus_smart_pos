import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../data/local/database.dart';
import '../data/remote/api_client.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager(ref);
});

class SyncManager {
  final Ref ref;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncManager(this.ref);

  Future<void> initialize() async {
    // Start periodic sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!_isSyncing) {
        syncPendingRecords();
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
    final apiClient = ref.read(apiClientProvider);

    // Get pending sync logs
    final pendingLogs = await db.query(
      'sync_logs',
      where: 'status = ?',
      whereArgs: ['pending'],
      limit: 50, // Batch size
    );

    if (pendingLogs.isEmpty) return;

    final records = <String, List<Map<String, dynamic>>>{};

    for (final log in pendingLogs) {
      final tableName = log['table_name'] as String;
      final recordId = log['record_id'] as int;

      // Get the actual record data
      final record = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [recordId],
      );

      if (record.isNotEmpty) {
        records[tableName] ??= [];
        records[tableName]!.add(record.first);
      }
    }

    try {
      // Upload to server
      await apiClient.uploadSyncData(records);

      // Mark as synced
      final batch = db.batch();
      for (final log in pendingLogs) {
        batch.update(
          'sync_logs',
          {
            'status': 'synced',
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [log['id']],
        );

        // Also mark the original record as synced
        batch.update(
          log['table_name'] as String,
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [log['record_id']],
        );
      }
      await batch.commit();
    } catch (e) {
      // Handle sync failure with exponential backoff
      await _handleSyncFailure(pendingLogs, e);
    }
  }

  Future<void> _handleSyncFailure(
    List<Map<String, dynamic>> failedLogs,
    Object error,
  ) async {
    final db = await AppDatabase.database;
    final batch = db.batch();

    for (final log in failedLogs) {
      final attempts = (log['sync_attempts'] as int?) ?? 0;
      final newAttempts = attempts + 1;

      batch.update(
        'sync_logs',
        {
          'sync_attempts': newAttempts,
          'last_sync_attempt': DateTime.now().millisecondsSinceEpoch,
          'error_message': error.toString(),
          'status': newAttempts >= 3 ? 'failed' : 'pending',
        },
        where: 'id = ?',
        whereArgs: [log['id']],
      );
    }

    await batch.commit();
  }

  Future<void> _downloadUpdates() async {
    final db = await AppDatabase.database;
    final apiClient = ref.read(apiClientProvider);

    // Get last sync timestamp
    final lastSync = await _getLastSyncTimestamp();

    try {
      final dynamic updatesResponse = await apiClient.downloadUpdates(lastSync);

      // Normalize the response to a Map<String, dynamic> if possible
      Map<String, dynamic>? updates;
      if (updatesResponse is Map<String, dynamic>) {
        updates = updatesResponse;
      } else if (updatesResponse != null) {
        // Try common conversion methods/fields used by DTOs
        try {
          final dynamic asJson = (updatesResponse as dynamic).toJson?.call() ??
              (updatesResponse as dynamic).toMap?.call() ??
              (updatesResponse as dynamic).data;
          if (asJson is Map) {
            updates = Map<String, dynamic>.from(asJson);
          }
        } catch (_) {
          // ignore and treat as no updates
        }
      }
      }

      if (updates != null && updates.isNotEmpty) {
        await _applyServerUpdates(updates);
      }
    } catch (e) {
      print('Download updates error: $e');
    }
  }

  Future<int> _getLastSyncTimestamp() async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery('''
      SELECT MAX(updated_at) as last_sync FROM sync_logs 
      WHERE status = 'synced'
    ''');

    return result.first['last_sync'] as int? ?? 0;
  }

  Future<void> _applyServerUpdates(Map<String, dynamic> updates) async {
    final db = await AppDatabase.database;
    final batch = db.batch();

    // Apply updates with server-wins conflict resolution
    for (final tableName in updates.keys) {
      final records = updates[tableName] as List<Map<String, dynamic>>;

      for (final record in records) {
        batch.insert(
          tableName,
          record,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit();
  }

  Future<void> forceSync() async {
    await syncPendingRecords();
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    final db = await AppDatabase.database;

    final pendingCount = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sync_logs WHERE status = 'pending'
    ''');

    final failedCount = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sync_logs WHERE status = 'failed'
    ''');

    return {
      'pending': pendingCount.first['count'] as int,
      'failed': failedCount.first['count'] as int,
      'isSyncing': _isSyncing,
    };
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
