import '../entities/proxy_node.dart';
import '../repositories/node_repository.dart';

/// Parses links from text, appends new nodes and persists them.
class AddNodesFromText {
  const AddNodesFromText(this._repo);
  final NodeRepository _repo;

  Future<({List<ProxyNode> nodes, int added})> call(String text) async {
    final parsed = _repo.parse(text);
    final current = await _repo.getNodes();
    final next = [...current, ...parsed];
    await _repo.saveNodes(next);
    return (nodes: next, added: parsed.length);
  }
}
