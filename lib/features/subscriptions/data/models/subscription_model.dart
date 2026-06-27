import '../../domain/entities/subscription.dart';

extension SubscriptionMapper on Subscription {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'nodeCount': nodeCount,
      };
}

Subscription subscriptionFromJson(Map<String, dynamic> j) => Subscription(
      id: j['id'] as String,
      name: j['name'] as String? ?? 'Subscription',
      url: j['url'] as String? ?? '',
      lastUpdated: j['lastUpdated'] != null
          ? DateTime.tryParse(j['lastUpdated'] as String)
          : null,
      nodeCount: (j['nodeCount'] as num?)?.toInt() ?? 0,
    );
