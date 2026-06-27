import '../entities/proxy_node.dart';

/// Persistence + parsing + latency for proxy nodes.
abstract class NodeRepository {
  Future<List<ProxyNode>> getNodes();
  Future<void> saveNodes(List<ProxyNode> nodes);

  /// Parses share links / base64 subscription text into nodes.
  List<ProxyNode> parse(String text);

  /// TCP-connect latency in ms, or -1 on failure.
  Future<int> measureLatency(ProxyNode node);
}
