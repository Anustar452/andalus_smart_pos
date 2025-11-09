import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:andalus_smart_pos/src/data/models/subscription.dart';

class SubscriptionRepository {
  SubscriptionRepository(); // Remove database parameter

  Future<void> createSubscription(Subscription subscription) async {
    final db = await AppDatabase.database;
    await db.insert('subscriptions', subscription.toMap());
  }

  Future<Subscription?> getActiveSubscription(String businessId) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'subscriptions',
      where: 'business_id = ? AND is_active = 1 AND end_date > ?',
      whereArgs: [businessId, DateTime.now().millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Subscription.fromMap(result.first);
  }

  Future<void> updateSubscription(Subscription subscription) async {
    final db = await AppDatabase.database;
    await db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'subscription_id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<List<Subscription>> getSubscriptionHistory(String businessId) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'subscriptions',
      where: 'business_id = ?',
      whereArgs: [businessId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Subscription.fromMap(map)).toList();
  }

  Future<bool> hasValidSubscription(String businessId) async {
    final subscription = await getActiveSubscription(businessId);
    return subscription != null && subscription.isValid;
  }

  Future<void> deactivateSubscription(String subscriptionId) async {
    final db = await AppDatabase.database;
    await db.update(
      'subscriptions',
      {
        'is_active': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'subscription_id = ?',
      whereArgs: [subscriptionId],
    );
  }
}
