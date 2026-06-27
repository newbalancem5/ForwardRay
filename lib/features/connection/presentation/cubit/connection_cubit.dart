import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../proxy/presentation/cubit/nodes_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/connection_status.dart';
import '../../domain/entities/traffic.dart';
import '../../domain/usecases/connect.dart';
import '../../domain/usecases/core_status.dart';
import '../../domain/usecases/disconnect.dart';
import '../../domain/usecases/get_totals.dart';
import '../../domain/usecases/watch_traffic.dart';

part 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionUiState> {
  ConnectionCubit({
    required Connect connect,
    required Disconnect disconnect,
    required WatchTraffic watchTraffic,
    required GetTotals getTotals,
    required IsCoreInstalled isCoreInstalled,
    required InstallCore installCore,
    required DownloadCore downloadCore,
    required SettingsCubit settingsCubit,
    required NodesCubit nodesCubit,
  })  : _connect = connect,
        _disconnect = disconnect,
        _watchTraffic = watchTraffic,
        _getTotals = getTotals,
        _isCoreInstalled = isCoreInstalled,
        _installCore = installCore,
        _downloadCore = downloadCore,
        _settings = settingsCubit,
        _nodes = nodesCubit,
        super(const ConnectionUiState());

  final Connect _connect;
  final Disconnect _disconnect;
  final WatchTraffic _watchTraffic;
  final GetTotals _getTotals;
  final IsCoreInstalled _isCoreInstalled;
  final InstallCore _installCore;
  final DownloadCore _downloadCore;
  final SettingsCubit _settings;
  final NodesCubit _nodes;

  StreamSubscription<TrafficSample>? _trafficSub;
  Timer? _totalsTimer;

  bool get isConnected => state.status == ConnectionStatus.connected;

  Future<void> init() async {
    await checkCore();
    if (!state.coreInstalled) {
      // First run: fetch the core automatically (don't block startup).
      unawaited(_autoSetup());
      return;
    }
    if (_settings.settings.autoConnectOnStart && _nodes.selectedNode != null) {
      await connect();
    }
  }

  /// Downloads the core on first launch, then optionally auto-connects.
  Future<void> _autoSetup() async {
    await downloadCore();
    if (state.coreInstalled &&
        _settings.settings.autoConnectOnStart &&
        _nodes.selectedNode != null) {
      await connect();
    }
  }

  Future<void> checkCore() async {
    emit(state.copyWith(coreInstalled: await _isCoreInstalled()));
  }

  Future<void> installCore(String sourcePath) async {
    await _installCore(sourcePath);
    await checkCore();
  }

  /// Downloads + installs the pinned sing-box core from GitHub releases.
  Future<void> downloadCore() async {
    if (state.coreDownloading) return;
    emit(state.copyWith(
        coreDownloading: true, coreDownloadProgress: 0, clearError: true));
    try {
      await _downloadCore(
        onProgress: (p) => emit(state.copyWith(coreDownloadProgress: p)),
      );
      final ok = await _isCoreInstalled();
      emit(state.copyWith(coreDownloading: false, coreInstalled: ok));
    } catch (e) {
      emit(state.copyWith(coreDownloading: false, error: '$e'));
    }
  }

  Future<void> toggle() => isConnected ? disconnect() : connect();

  Future<void> connect() async {
    final node = _nodes.selectedNode;
    if (node == null) {
      emit(state.copyWith(
          status: ConnectionStatus.error, error: 'NO_NODE'));
      return;
    }
    if (state.status == ConnectionStatus.connecting) return;

    emit(state.copyWith(status: ConnectionStatus.connecting, clearError: true));
    try {
      await _connect(node, _settings.settings);
      _startMonitor();
      emit(state.copyWith(status: ConnectionStatus.connected, clearError: true));
    } on CoreNotFoundFailure {
      emit(state.copyWith(
          status: ConnectionStatus.error,
          error: 'CORE_NOT_FOUND',
          coreInstalled: false));
    } on Failure catch (f) {
      emit(state.copyWith(status: ConnectionStatus.error, error: f.message));
      await _safeStop();
    } catch (e) {
      emit(state.copyWith(status: ConnectionStatus.error, error: '$e'));
      await _safeStop();
    }
  }

  Future<void> disconnect() async {
    await _safeStop();
    emit(state.copyWith(
      status: ConnectionStatus.disconnected,
      traffic: TrafficSample.zero,
      clearError: true,
    ));
  }

  /// Re-applies the connection (e.g. after switching node or settings).
  Future<void> reconnectIfActive() async {
    if (!isConnected && state.status != ConnectionStatus.connecting) return;
    await disconnect();
    await connect();
  }

  void _startMonitor() {
    _trafficSub?.cancel();
    _trafficSub = _watchTraffic().listen(
      (sample) => emit(state.copyWith(traffic: sample)),
      onError: (_) {},
    );
    _totalsTimer?.cancel();
    _totalsTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      emit(state.copyWith(totals: await _getTotals()));
    });
  }

  Future<void> _safeStop() async {
    _trafficSub?.cancel();
    _trafficSub = null;
    _totalsTimer?.cancel();
    _totalsTimer = null;
    await _disconnect();
  }

  @override
  Future<void> close() async {
    await _safeStop();
    return super.close();
  }
}
