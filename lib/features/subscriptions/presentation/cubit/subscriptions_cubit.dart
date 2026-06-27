import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../proxy/presentation/cubit/nodes_cubit.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/usecases/add_subscription.dart';
import '../../domain/usecases/delete_subscription.dart';
import '../../domain/usecases/get_subscriptions.dart';
import '../../domain/usecases/update_subscription.dart';

part 'subscriptions_state.dart';

class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  SubscriptionsCubit({
    required GetSubscriptions getSubscriptions,
    required AddSubscription addSubscription,
    required UpdateSubscription updateSubscription,
    required DeleteSubscription deleteSubscription,
    required NodesCubit nodesCubit,
  })  : _getSubscriptions = getSubscriptions,
        _addSubscription = addSubscription,
        _updateSubscription = updateSubscription,
        _deleteSubscription = deleteSubscription,
        _nodes = nodesCubit,
        super(const SubscriptionsState());

  final GetSubscriptions _getSubscriptions;
  final AddSubscription _addSubscription;
  final UpdateSubscription _updateSubscription;
  final DeleteSubscription _deleteSubscription;
  final NodesCubit _nodes;

  Future<void> load() async {
    emit(state.copyWith(subscriptions: await _getSubscriptions()));
  }

  Future<void> add(String name, String url) async {
    final sub = await _addSubscription(name, url);
    emit(state.copyWith(subscriptions: [...state.subscriptions, sub]));
    await update(sub.id);
  }

  Future<void> update(String id) async {
    emit(state.copyWith(updating: {...state.updating, id}, clearError: true));
    try {
      final result = await _updateSubscription(id);
      await _nodes.replaceAll(result.nodes);
      emit(state.copyWith(
        subscriptions: result.subs,
        updating: {...state.updating}..remove(id),
      ));
    } catch (e) {
      emit(state.copyWith(
        error: '$e',
        updating: {...state.updating}..remove(id),
      ));
    }
  }

  Future<void> updateAll() async {
    for (final s in state.subscriptions) {
      await update(s.id);
    }
  }

  Future<void> delete(String id, {bool keepNodes = false}) async {
    final result = await _deleteSubscription(id, keepNodes: keepNodes);
    await _nodes.replaceAll(result.nodes);
    emit(state.copyWith(subscriptions: result.subs));
  }
}
