import 'package:uuid/uuid.dart';

import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

/// Creates and persists a subscription (without fetching yet). Returns the new
/// entry so the caller can immediately update it.
class AddSubscription {
  const AddSubscription(this._repo);
  final SubscriptionRepository _repo;

  Future<Subscription> call(String name, String url) async {
    final sub = Subscription(id: const Uuid().v4(), name: name, url: url);
    final subs = await _repo.getSubscriptions();
    await _repo.saveSubscriptions([...subs, sub]);
    return sub;
  }
}
