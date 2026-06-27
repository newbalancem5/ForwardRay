import '../entities/proxy_node.dart';
import '../repositories/node_repository.dart';

class DeleteNode {
  const DeleteNode(this._repo);
  final NodeRepository _repo;

  Future<List<ProxyNode>> call(String id) async {
    final next = (await _repo.getNodes()).where((n) => n.id != id).toList();
    await _repo.saveNodes(next);
    return next;
  }
}
