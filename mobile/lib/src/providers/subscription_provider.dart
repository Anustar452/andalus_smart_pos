// providers/subscription_provider.dart
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

final currentSubscriptionProvider = FutureProvider<Subscription?>((ref) async {
  final repository = ref.read(subscriptionRepositoryProvider);
  return await repository.getCurrentSubscription();
});
