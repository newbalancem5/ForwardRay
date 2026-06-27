import 'dart:convert';

import '../../../../core/storage/app_paths.dart';
import '../../domain/entities/proxy_node.dart';
import '../models/proxy_node_model.dart';

/// Reads/writes the persisted node list (nodes.json).
class NodeLocalDataSource {
  NodeLocalDataSource(this._paths);
  final AppPaths _paths;

  Future<List<ProxyNode>> read() async {
    final file = _paths.file('nodes.json');
    if (!file.existsSync()) return [];
    try {
      final list = jsonDecode(await file.readAsString()) as List;
      return list
          .map((e) => proxyNodeFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> write(List<ProxyNode> nodes) async {
    await _paths
        .file('nodes.json')
        .writeAsString(jsonEncode(nodes.map((n) => n.toJson()).toList()));
  }
}
