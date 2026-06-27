import '../../../proxy/data/datasources/link_parser.dart';
import '../../../proxy/domain/entities/proxy_node.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required SubscriptionLocalDataSource local,
    required SubscriptionRemoteDataSource remote,
    required LinkParser parser,
  })  : _local = local,
        _remote = remote,
        _parser = parser;

  final SubscriptionLocalDataSource _local;
  final SubscriptionRemoteDataSource _remote;
  final LinkParser _parser;

  @override
  Future<List<Subscription>> getSubscriptions() => _local.read();

  @override
  Future<void> saveSubscriptions(List<Subscription> subs) => _local.write(subs);

  @override
  Future<List<ProxyNode>> fetch(Subscription sub) async {
    final body = await _remote.download(sub.url);
    final nodes = _parser.parseMany(body);
    return nodes.map((n) => n.copyWith(subscriptionId: sub.id)).toList();
  }
}
