part of 'nodes_cubit.dart';

class NodesState extends Equatable {
  const NodesState({
    this.nodes = const [],
    this.latencies = const {},
    this.pinging = false,
  });

  final List<ProxyNode> nodes;
  final Map<String, int?> latencies;
  final bool pinging;

  NodesState copyWith({
    List<ProxyNode>? nodes,
    Map<String, int?>? latencies,
    bool? pinging,
  }) =>
      NodesState(
        nodes: nodes ?? this.nodes,
        latencies: latencies ?? this.latencies,
        pinging: pinging ?? this.pinging,
      );

  @override
  List<Object?> get props => [nodes, latencies, pinging];
}
