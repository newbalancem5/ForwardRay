import '../entities/traffic.dart';
import '../repositories/connection_repository.dart';

class GetTotals {
  const GetTotals(this._repo);
  final ConnectionRepository _repo;

  Future<TrafficTotals> call() => _repo.getTotals();
}
