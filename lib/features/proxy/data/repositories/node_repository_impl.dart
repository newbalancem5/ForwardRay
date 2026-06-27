import '../../domain/entities/proxy_node.dart';
import '../../domain/repositories/node_repository.dart';
import '../datasources/link_parser.dart';
import '../datasources/node_local_datasource.dart';
import '../datasources/tcp_pinger.dart';

class NodeRepositoryImpl implements NodeRepository {
  NodeRepositoryImpl({
    required NodeLocalDataSource local,
    required LinkParser parser,
    required TcpPinger pinger,
  })  : _local = local,
        _parser = parser,
        _pinger = pinger;

  final NodeLocalDataSource _local;
  final LinkParser _parser;
  final TcpPinger _pinger;

  @override
  Future<List<ProxyNode>> getNodes() => _local.read();

  @override
  Future<void> saveNodes(List<ProxyNode> nodes) => _local.write(nodes);

  @override
  List<ProxyNode> parse(String text) => _parser.parseMany(text);

  @override
  Future<int> measureLatency(ProxyNode node) =>
      _pinger.measure(node.server, node.port);
}
