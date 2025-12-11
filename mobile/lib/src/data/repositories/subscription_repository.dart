// mobile/lib/src/data/repositories/subscription_repository.dart
// Repository for managing subscription data in the local database.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/database.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  Future<Database> get _db async => await AppDatabase.database;

  Future<Subscription?> getCurrentSubscription() async {
    final db = await _db;

    try {
      final maps = await db.query(
        'subscriptions',
        where: 'is_active = 1',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return Subscription.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error fetching current subscription: $e');
      return null;
    }
  }

  Future<List<Subscription>> getSubscriptionHistory() async {
    final db = await _db;

    try {
      final maps = await db.query(
        'subscriptions',
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => Subscription.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching subscription history: $e');
      return [];
    }
  }

  Future<void> createSubscription(Subscription subscription) async {
    final db = await _db;

    try {
      await db.insert(
        'subscriptions',
        subscription.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error creating subscription: $e');
      rethrow;
    }
  }

  Future hasValidSubscription(String s) async {
    final subscription = await getCurrentSubscription();
    if (subscription == null) {
      return false;
    }
    final now = DateTime.now();
    return subscription.expiryDate.isAfter(now);
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});
