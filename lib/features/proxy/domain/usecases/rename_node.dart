import '../entities/proxy_node.dart';
import '../repositories/node_repository.dart';

class RenameNode {
  const RenameNode(this._repo);
  final NodeRepository _repo;

  Future<List<ProxyNode>> call(String id, String name) async {
    final next = (await _repo.getNodes())
        .map((n) => n.id == id ? n.copyWith(name: name) : n)
        .toList();
    await _repo.saveNodes(next);
    return next;
  }
}
