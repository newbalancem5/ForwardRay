import 'package:equatable/equatable.dart';

/// A remote subscription that yields a list of proxy nodes.
class Subscription extends Equatable {
  const Subscription({
    required this.id,
    required this.name,
    required this.url,
    this.lastUpdated,
    this.nodeCount = 0,
  });

  final String id;
  final String name;
  final String url;
  final DateTime? lastUpdated;
  final int nodeCount;

  Subscription copyWith({
    String? name,
    String? url,
    DateTime? lastUpdated,
    int? nodeCount,
  }) =>
      Subscription(
        id: id,
        name: name ?? this.name,
        url: url ?? this.url,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        nodeCount: nodeCount ?? this.nodeCount,
      );

  @override
  List<Object?> get props => [id, name, url, lastUpdated, nodeCount];
}
