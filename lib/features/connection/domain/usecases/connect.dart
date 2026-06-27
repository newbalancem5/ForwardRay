import '../../../proxy/domain/entities/proxy_node.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../repositories/connection_repository.dart';

class Connect {
  const Connect(this._repo);
  final ConnectionRepository _repo;

  Future<void> call(ProxyNode node, AppSettings settings) =>
      _repo.connect(node, settings);
}
