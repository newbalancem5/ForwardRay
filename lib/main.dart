import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'core/di/injector.dart';
import 'core/network/ca_http_overrides.dart';
import 'features/connection/presentation/cubit/connection_cubit.dart';
import 'features/proxy/presentation/cubit/nodes_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/subscriptions/presentation/cubit/subscriptions_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Trust the bundled Mozilla CA set so HTTPS works on Windows too.
  await CaHttpOverrides.install();

  await configureDependencies();

  // Load persisted state before the first frame (theme/locale depend on it).
  await getIt<SettingsCubit>().load();
  await getIt<NodesCubit>().load();
  await getIt<SubscriptionsCubit>().load();

  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1000, 700),
    minimumSize: Size(840, 580),
    center: true,
    title: 'ForwardRay',
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true); // close hides to tray
  });

  // Core check + optional auto-connect.
  await getIt<ConnectionCubit>().init();

  runApp(const ForwardRayApp());
}
