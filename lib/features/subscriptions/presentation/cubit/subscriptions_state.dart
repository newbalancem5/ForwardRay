part of 'subscriptions_cubit.dart';

class SubscriptionsState extends Equatable {
  const SubscriptionsState({
    this.subscriptions = const [],
    this.updating = const {},
    this.error,
  });

  final List<Subscription> subscriptions;
  final Set<String> updating;
  final String? error;

  SubscriptionsState copyWith({
    List<Subscription>? subscriptions,
    Set<String>? updating,
    String? error,
    bool clearError = false,
  }) =>
      SubscriptionsState(
        subscriptions: subscriptions ?? this.subscriptions,
        updating: updating ?? this.updating,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [subscriptions, updating, error];
}
