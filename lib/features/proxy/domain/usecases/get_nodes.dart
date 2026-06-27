import '../entities/proxy_node.dart';
import '../repositories/node_repository.dart';

class GetNodes {
  const GetNodes(this._repo);
  final NodeRepository _repo;

  Future<List<ProxyNode>> call() => _repo.getNodes();
}
