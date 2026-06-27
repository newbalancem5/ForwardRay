import '../../../proxy/domain/entities/proxy_node.dart';
import '../../../proxy/domain/repositories/node_repository.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class DeleteSubscription {
  const DeleteSubscription(this._subRepo, this._nodeRepo);
  final SubscriptionRepository _subRepo;
  final NodeRepository _nodeRepo;

  Future<({List<Subscription> subs, List<ProxyNode> nodes})> call(
    String id, {
    bool keepNodes = false,
  }) async {
    final subs =
        (await _subRepo.getSubscriptions()).where((s) => s.id != id).toList();
    await _subRepo.saveSubscriptions(subs);

    var nodes = await _nodeRepo.getNodes();
    if (!keepNodes) {
      nodes = nodes.where((n) => n.subscriptionId != id).toList();
      await _nodeRepo.saveNodes(nodes);
    }
    return (subs: subs, nodes: nodes);
  }
}
