import 'package:get_it/get_it.dart';

import '../../features/connection/data/datasources/clash_api_client.dart';
import '../../features/connection/data/datasources/config_builder.dart';
import '../../features/connection/data/datasources/core_downloader.dart';
import '../../features/connection/data/datasources/singbox_process.dart';
import '../../features/connection/data/datasources/system_proxy_manager.dart';
import '../../features/connection/data/repositories/connection_repository_impl.dart';
import '../../features/connection/domain/repositories/connection_repository.dart';
import '../../features/connection/domain/usecases/connect.dart';
import '../../features/connection/domain/usecases/core_status.dart';
import '../../features/connection/domain/usecases/disconnect.dart';
import '../../features/connection/domain/usecases/get_totals.dart';
import '../../features/connection/domain/usecases/watch_traffic.dart';
import '../../features/connection/presentation/cubit/connection_cubit.dart';
import '../../features/proxy/data/datasources/link_parser.dart';
import '../../features/proxy/data/datasources/node_local_datasource.dart';
import '../../features/proxy/data/datasources/tcp_pinger.dart';
import '../../features/proxy/data/repositories/node_repository_impl.dart';
import '../../features/proxy/domain/repositories/node_repository.dart';
import '../../features/proxy/domain/usecases/add_nodes_from_text.dart';
import '../../features/proxy/domain/usecases/delete_node.dart';
import '../../features/proxy/domain/usecases/get_nodes.dart';
import '../../features/proxy/domain/usecases/measure_latency.dart';
import '../../features/proxy/domain/usecases/rename_node.dart';
import '../../features/proxy/presentation/cubit/nodes_cubit.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/save_settings.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/subscriptions/data/datasources/subscription_local_datasource.dart';
import '../../features/subscriptions/data/datasources/subscription_remote_datasource.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../../features/subscriptions/domain/usecases/add_subscription.dart';
import '../../features/subscriptions/domain/usecases/delete_subscription.dart';
import '../../features/subscriptions/domain/usecases/get_subscriptions.dart';
import '../../features/subscriptions/domain/usecases/update_subscription.dart';
import '../../features/subscriptions/presentation/cubit/subscriptions_cubit.dart';
import '../storage/app_paths.dart';

final getIt = GetIt.instance;

/// Wires the whole object graph: core → datasources → repositories →
/// usecases → cubits.
Future<void> configureDependencies() async {
  // --- Core ---
  getIt.registerSingleton<AppPaths>(await AppPaths.init());

  // --- Data sources ---
  getIt
    ..registerLazySingleton(() => const LinkParser())
    ..registerLazySingleton(() => const TcpPinger())
    ..registerLazySingleton(() => NodeLocalDataSource(getIt()))
    ..registerLazySingleton(() => const ConfigBuilder())
    ..registerLazySingleton(() => const SystemProxyManager())
    ..registerLazySingleton(() => SingBoxProcess(getIt()))
    ..registerLazySingleton(() => CoreDownloader(getIt()))
    ..registerLazySingleton(() => SubscriptionLocalDataSource(getIt()))
    ..registerLazySingleton(() => const SubscriptionRemoteDataSource())
    ..registerLazySingleton(() => SettingsLocalDataSource(getIt()));

  // Used directly by the connection repository, registered for completeness.
  getIt.registerFactoryParam<ClashApiClient, int, String>(
    (port, secret) => ClashApiClient(port: port, secret: secret),
  );

  // --- Repositories ---
  getIt
    ..registerLazySingleton<NodeRepository>(() => NodeRepositoryImpl(
          local: getIt(),
          parser: getIt(),
          pinger: getIt(),
        ))
    ..registerLazySingleton<ConnectionRepository>(() => ConnectionRepositoryImpl(
          paths: getIt(),
          process: getIt(),
          configBuilder: getIt(),
          systemProxy: getIt(),
          coreDownloader: getIt(),
        ))
    ..registerLazySingleton<SubscriptionRepository>(
        () => SubscriptionRepositoryImpl(
              local: getIt(),
              remote: getIt(),
              parser: getIt(),
            ))
    ..registerLazySingleton<SettingsRepository>(
        () => SettingsRepositoryImpl(getIt()));

  // --- Use cases ---
  getIt
    // settings
    ..registerLazySingleton(() => GetSettings(getIt()))
    ..registerLazySingleton(() => SaveSettings(getIt()))
    // proxy
    ..registerLazySingleton(() => GetNodes(getIt()))
    ..registerLazySingleton(() => AddNodesFromText(getIt()))
    ..registerLazySingleton(() => DeleteNode(getIt()))
    ..registerLazySingleton(() => RenameNode(getIt()))
    ..registerLazySingleton(() => MeasureLatency(getIt()))
    // connection
    ..registerLazySingleton(() => Connect(getIt()))
    ..registerLazySingleton(() => Disconnect(getIt()))
    ..registerLazySingleton(() => WatchTraffic(getIt()))
    ..registerLazySingleton(() => GetTotals(getIt()))
    ..registerLazySingleton(() => IsCoreInstalled(getIt()))
    ..registerLazySingleton(() => InstallCore(getIt()))
    ..registerLazySingleton(() => DownloadCore(getIt()))
    // subscriptions
    ..registerLazySingleton(() => GetSubscriptions(getIt()))
    ..registerLazySingleton(() => AddSubscription(getIt()))
    ..registerLazySingleton(
        () => UpdateSubscription(getIt(), getIt()))
    ..registerLazySingleton(
        () => DeleteSubscription(getIt(), getIt()));

  // --- Cubits (app-lifetime singletons) ---
  getIt
    ..registerLazySingleton(() => SettingsCubit(
          getSettings: getIt(),
          saveSettings: getIt(),
        ))
    ..registerLazySingleton(() => NodesCubit(
          getNodes: getIt(),
          addNodesFromText: getIt(),
          deleteNode: getIt(),
          renameNode: getIt(),
          measureLatency: getIt(),
          settingsCubit: getIt(),
        ))
    ..registerLazySingleton(() => ConnectionCubit(
          connect: getIt(),
          disconnect: getIt(),
          watchTraffic: getIt(),
          getTotals: getIt(),
          isCoreInstalled: getIt(),
          installCore: getIt(),
          downloadCore: getIt(),
          settingsCubit: getIt(),
          nodesCubit: getIt(),
        ))
    ..registerLazySingleton(() => SubscriptionsCubit(
          getSubscriptions: getIt(),
          addSubscription: getIt(),
          updateSubscription: getIt(),
          deleteSubscription: getIt(),
          nodesCubit: getIt(),
        ));
}
