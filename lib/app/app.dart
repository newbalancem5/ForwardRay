import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injector.dart';
import '../core/theme/app_theme.dart';
import '../features/connection/presentation/cubit/connection_cubit.dart';
import '../features/proxy/presentation/cubit/nodes_cubit.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import '../features/subscriptions/presentation/cubit/subscriptions_cubit.dart';
import '../l10n/app_localizations.dart';
import 'app_shell.dart';

class ForwardRayApp extends StatelessWidget {
  const ForwardRayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<SettingsCubit>()),
        BlocProvider.value(value: getIt<NodesCubit>()),
        BlocProvider.value(value: getIt<ConnectionCubit>()),
        BlocProvider.value(value: getIt<SubscriptionsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, _) {
          final settings = context.read<SettingsCubit>();
          return MaterialApp(
            onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
