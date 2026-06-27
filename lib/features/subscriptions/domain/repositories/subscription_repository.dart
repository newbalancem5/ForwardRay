import '../../../proxy/domain/entities/proxy_node.dart';
import '../entities/subscription.dart';

/// Persistence + remote fetching of subscriptions.
abstract class SubscriptionRepository {
  Future<List<Subscription>> getSubscriptions();
  Future<void> saveSubscriptions(List<Subscription> subs);

  /// Downloads and parses a subscription into nodes tagged with its id.
  Future<List<ProxyNode>> fetch(Subscription sub);
}
