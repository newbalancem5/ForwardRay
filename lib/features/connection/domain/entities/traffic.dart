import 'package:equatable/equatable.dart';

/// Instantaneous traffic, bytes per second.
class TrafficSample extends Equatable {
  const TrafficSample(this.up, this.down);
  final int up;
  final int down;
  static const zero = TrafficSample(0, 0);

  @override
  List<Object?> get props => [up, down];
}

/// Cumulative totals since the core started.
class TrafficTotals extends Equatable {
  const TrafficTotals(this.up, this.down);
  final int up;
  final int down;
  static const zero = TrafficTotals(0, 0);

  @override
  List<Object?> get props => [up, down];
}
