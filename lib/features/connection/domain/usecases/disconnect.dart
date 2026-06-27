import '../repositories/connection_repository.dart';

class Disconnect {
  const Disconnect(this._repo);
  final ConnectionRepository _repo;

  Future<void> call() => _repo.disconnect();
}
