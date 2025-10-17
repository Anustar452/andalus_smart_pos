// mobile/lib/src/services/sync_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'api_service.dart';
import 'local_db_service.dart';

class SyncService {
  final Ref ref;

  SyncService(this.ref);

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> syncData() async {
    final isConnected = await isOnline();
    if (!isConnected) return;

    final localDb = ref.read(localDbServiceProvider);
    final apiService = ref.read(apiServiceProvider);

    try {
      // Sync pending transactions
      final pendingTransactions = await localDb.getTransactions();
      for (final transaction in pendingTransactions) {
        try {
          // Convert to API format and send
          final items = transaction.items
              .map(
                (item) => {
                  'product_id': item.productId,
                  'quantity': item.quantity,
                  'unit_price': item.unitPrice,
                },
              )
              .toList();

          await apiService.createTransaction(
            items: items,
            paymentMethod: transaction.paymentMethod,
            paidAmount: transaction.paidAmount,
          );

          // Mark as synced
          // Note: You'll need to add this method to LocalDbService
        } catch (e) {
          print(
            'Failed to sync transaction ${transaction.transactionNumber}: $e',
          );
        }
      }

      // Sync other pending operations from sync_queue
      final syncQueue = await localDb.getSyncQueue();
      for (final item in syncQueue) {
        try {
          final data = jsonDecode(item['data'] as String);

          switch (item['table_name'] as String) {
            case 'products':
              // Handle product sync
              break;
            // Add other cases as needed
          }

          await localDb.removeFromSyncQueue(item['id'] as int);
        } catch (e) {
          print('Failed to sync queue item ${item['id']}: $e');
        }
      }

      // Pull latest products from server
      final latestProducts = await apiService.getProducts();
      for (final product in latestProducts) {
        await localDb.insertProduct(product);
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  Future<void> scheduleSync() async {
    // Sync every 5 minutes when online
    const syncInterval = Duration(minutes: 5);

    Future.delayed(syncInterval, () async {
      await syncData();
      scheduleSync(); // Reschedule
    });
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});
