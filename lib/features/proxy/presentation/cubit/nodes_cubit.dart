import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/proxy_node.dart';
import '../../domain/usecases/add_nodes_from_text.dart';
import '../../domain/usecases/delete_node.dart';
import '../../domain/usecases/get_nodes.dart';
import '../../domain/usecases/measure_latency.dart';
import '../../domain/usecases/rename_node.dart';

part 'nodes_state.dart';

class NodesCubit extends Cubit<NodesState> {
  NodesCubit({
    required GetNodes getNodes,
    required AddNodesFromText addNodesFromText,
    required DeleteNode deleteNode,
    required RenameNode renameNode,
    required MeasureLatency measureLatency,
    required SettingsCubit settingsCubit,
  })  : _getNodes = getNodes,
        _addNodesFromText = addNodesFromText,
        _deleteNode = deleteNode,
        _renameNode = renameNode,
        _measureLatency = measureLatency,
        _settings = settingsCubit,
        super(const NodesState());

  final GetNodes _getNodes;
  final AddNodesFromText _addNodesFromText;
  final DeleteNode _deleteNode;
  final RenameNode _renameNode;
  final MeasureLatency _measureLatency;
  final SettingsCubit _settings;

  ProxyNode? get selectedNode {
    final id = _settings.settings.selectedNodeId;
    if (state.nodes.isEmpty) return null;
    for (final n in state.nodes) {
      if (n.id == id) return n;
    }
    return state.nodes.first;
  }

  Future<void> load() async {
    final nodes = await _getNodes();
    emit(state.copyWith(nodes: nodes));
    await _ensureSelection(nodes);
  }

  /// Pushes an externally-updated node list into state (e.g. after a
  /// subscription refresh) and fixes selection.
  Future<void> replaceAll(List<ProxyNode> nodes) async {
    emit(state.copyWith(nodes: nodes));
    await _ensureSelection(nodes);
  }

  Future<int> addFromText(String text) async {
    final result = await _addNodesFromText(text);
    emit(state.copyWith(nodes: result.nodes));
    await _ensureSelection(result.nodes);
    return result.added;
  }

  Future<void> delete(String id) async {
    final nodes = await _deleteNode(id);
    emit(state.copyWith(nodes: nodes));
    if (_settings.settings.selectedNodeId == id) {
      await _settings.selectNode(nodes.isNotEmpty ? nodes.first.id : null);
    }
  }

  Future<void> rename(String id, String name) async {
    emit(state.copyWith(nodes: await _renameNode(id, name)));
  }

  Future<void> ping(String id) async {
    final node = state.nodes.firstWhere((n) => n.id == id);
    final ms = await _measureLatency(node);
    emit(state.copyWith(latencies: {...state.latencies, id: ms}));
  }

  Future<void> pingAll() async {
    emit(state.copyWith(pinging: true));
    await Future.wait(state.nodes.map((n) async {
      final ms = await _measureLatency(n);
      emit(state.copyWith(latencies: {...state.latencies, n.id: ms}));
    }));
    emit(state.copyWith(pinging: false));
  }

  Future<void> _ensureSelection(List<ProxyNode> nodes) async {
    final selected = _settings.settings.selectedNodeId;
    final exists = nodes.any((n) => n.id == selected);
    if (!exists) {
      await _settings.selectNode(nodes.isNotEmpty ? nodes.first.id : null);
    }
  }
}
