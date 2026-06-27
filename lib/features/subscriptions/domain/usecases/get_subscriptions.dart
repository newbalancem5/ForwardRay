import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptions {
  const GetSubscriptions(this._repo);
  final SubscriptionRepository _repo;

  Future<List<Subscription>> call() => _repo.getSubscriptions();
}
