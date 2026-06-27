import '../../../proxy/domain/entities/proxy_node.dart';
import '../../../proxy/domain/repositories/node_repository.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

/// Fetches a subscription, replaces the nodes belonging to it and updates its
/// metadata. Returns the refreshed subscription + full node lists.
class UpdateSubscription {
  const UpdateSubscription(this._subRepo, this._nodeRepo, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final SubscriptionRepository _subRepo;
  final NodeRepository _nodeRepo;
  final DateTime Function() _now;

  Future<({List<Subscription> subs, List<ProxyNode> nodes})> call(
      String subscriptionId) async {
    final subs = await _subRepo.getSubscriptions();
    final idx = subs.indexWhere((s) => s.id == subscriptionId);
    if (idx < 0) {
      return (subs: subs, nodes: await _nodeRepo.getNodes());
    }
    final sub = subs[idx];
    final fetched = await _subRepo.fetch(sub);

    final nodes = await _nodeRepo.getNodes();
    final kept = nodes.where((n) => n.subscriptionId != subscriptionId).toList();
    final nextNodes = [...kept, ...fetched];
    await _nodeRepo.saveNodes(nextNodes);

    final nextSubs = [...subs];
    nextSubs[idx] = sub.copyWith(
      lastUpdated: _now(),
      nodeCount: fetched.length,
    );
    await _subRepo.saveSubscriptions(nextSubs);

    return (subs: nextSubs, nodes: nextNodes);
  }
}
