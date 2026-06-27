import 'dart:convert';
import 'dart:io';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/app_paths.dart';
import '../../../proxy/domain/entities/proxy_node.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/traffic.dart';
import '../../domain/repositories/connection_repository.dart';
import '../datasources/clash_api_client.dart';
import '../datasources/config_builder.dart';
import '../datasources/core_downloader.dart';
import '../datasources/singbox_process.dart';
import '../datasources/system_proxy_manager.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  ConnectionRepositoryImpl({
    required AppPaths paths,
    required SingBoxProcess process,
    required ConfigBuilder configBuilder,
    required SystemProxyManager systemProxy,
    required CoreDownloader coreDownloader,
  })  : _paths = paths,
        _process = process,
        _configBuilder = configBuilder,
        _systemProxy = systemProxy,
        _coreDownloader = coreDownloader;

  final AppPaths _paths;
  final SingBoxProcess _process;
  final ConfigBuilder _configBuilder;
  final SystemProxyManager _systemProxy;
  final CoreDownloader _coreDownloader;

  ClashApiClient? _clash;

  @override
  Future<void> connect(ProxyNode node, AppSettings settings) async {
    final config = _configBuilder.build(
      node: node,
      settings: settings,
      cacheDir: _paths.cacheDir,
    );
    const encoder = JsonEncoder.withIndent('  ');
    await File(_paths.configPath).writeAsString(encoder.convert(config));

    final err = await _process.start();
    if (err != null) {
      if (err == 'CORE_NOT_FOUND') throw const CoreNotFoundFailure();
      if (err.startsWith('CONFIG_INVALID:')) {
        throw ConfigFailure(err.substring('CONFIG_INVALID:'.length));
      }
      throw CoreStartFailure(err.replaceFirst('START_FAILED:', ''));
    }

    _clash =
        ClashApiClient(port: settings.clashApiPort, secret: settings.clashApiSecret);

    if (!await _waitForCore()) {
      await _process.stop();
      throw const CoreStartFailure('Clash API did not respond');
    }

    await _systemProxy.enable(settings.localPort);
  }

  Future<bool> _waitForCore() async {
    for (var i = 0; i < 25; i++) {
      if (!_process.isRunning) return false;
      if (await _clash!.ping()) return true;
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return false;
  }

  @override
  Future<void> disconnect() async {
    _clash?.closeTraffic();
    try {
      await _systemProxy.disable();
    } catch (_) {}
    await _process.stop();
    _clash = null;
  }

  @override
  Stream<TrafficSample> watchTraffic() {
    final clash = _clash;
    if (clash == null) return const Stream.empty();
    return clash.trafficStream();
  }

  @override
  Future<TrafficTotals> getTotals() async =>
      await _clash?.totals() ?? TrafficTotals.zero;

  @override
  Future<bool> isCoreInstalled() async =>
      (await _process.resolveBinary()) != null;

  @override
  Future<void> installCore(String sourcePath) =>
      _process.installBinary(sourcePath);

  @override
  Future<void> downloadCore({void Function(double progress)? onProgress}) =>
      _coreDownloader.download(AppConstants.singBoxVersion,
          onProgress: onProgress);
}
