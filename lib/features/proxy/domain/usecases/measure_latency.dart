import '../entities/proxy_node.dart';
import '../repositories/node_repository.dart';

class MeasureLatency {
  const MeasureLatency(this._repo);
  final NodeRepository _repo;

  Future<int> call(ProxyNode node) => _repo.measureLatency(node);
}
