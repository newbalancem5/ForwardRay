import '../entities/traffic.dart';
import '../repositories/connection_repository.dart';

class WatchTraffic {
  const WatchTraffic(this._repo);
  final ConnectionRepository _repo;

  Stream<TrafficSample> call() => _repo.watchTraffic();
}
