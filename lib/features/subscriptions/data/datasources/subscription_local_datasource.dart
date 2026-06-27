import 'dart:convert';

import '../../../../core/storage/app_paths.dart';
import '../../domain/entities/subscription.dart';
import '../models/subscription_model.dart';

class SubscriptionLocalDataSource {
  SubscriptionLocalDataSource(this._paths);
  final AppPaths _paths;

  Future<List<Subscription>> read() async {
    final file = _paths.file('subscriptions.json');
    if (!file.existsSync()) return [];
    try {
      final list = jsonDecode(await file.readAsString()) as List;
      return list
          .map((e) => subscriptionFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> write(List<Subscription> subs) async {
    await _paths
        .file('subscriptions.json')
        .writeAsString(jsonEncode(subs.map((s) => s.toJson()).toList()));
  }
}
