import '../../../proxy/domain/entities/proxy_node.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../entities/traffic.dart';

/// Controls the proxy core process, system proxy and live traffic.
abstract class ConnectionRepository {
  /// Builds the config, starts the core, waits for it and applies the system
  /// proxy. Throws a [Failure] on any error.
  Future<void> connect(ProxyNode node, AppSettings settings);

  /// Tears down the system proxy and stops the core.
  Future<void> disconnect();

  /// Live up/down speed (bytes per second) from the Clash API.
  Stream<TrafficSample> watchTraffic();

  /// Cumulative totals since connect.
  Future<TrafficTotals> getTotals();

  /// Whether a usable sing-box binary is available.
  Future<bool> isCoreInstalled();

  /// Installs a sing-box binary from [sourcePath].
  Future<void> installCore(String sourcePath);

  /// Downloads + installs the pinned sing-box core, reporting 0..1 progress.
  Future<void> downloadCore({void Function(double progress)? onProgress});
}
