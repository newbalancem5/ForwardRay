import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/common.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../connection/presentation/cubit/connection_cubit.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';

class RoutingPage extends StatelessWidget {
  const RoutingPage({super.key});

  String _modeLabel(AppLocalizations l, RoutingMode mode) => switch (mode) {
        RoutingMode.global => l.modeGlobal,
        RoutingMode.rule => l.modeRule,
        RoutingMode.direct => l.modeDirect,
      };

  IconData _modeIcon(RoutingMode mode) => switch (mode) {
        RoutingMode.global => Icons.public,
        RoutingMode.rule => Icons.account_tree_outlined,
        RoutingMode.direct => Icons.arrow_forward,
      };

  Future<void> _save(BuildContext context, AppSettings next) async {
    await context.read<SettingsCubit>().save(next);
    await context.read<ConnectionCubit>().reconnectIfActive();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return PageScaffold(
      title: l.navRouting,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settings = state.settings;
          final mode = settings.routingMode;
          final isDirect = mode == RoutingMode.direct;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(l.routingMode),
                    Text(
                      l.routingModeDesc,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...RoutingMode.values.map((m) {
                      return RadioListTile<RoutingMode>(
                        value: m,
                        groupValue: mode,
                        onChanged: (value) {
                          if (value != null) {
                            _save(context, settings.copyWith(routingMode: value));
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(_modeIcon(m)),
                        title: Text(_modeLabel(l, m)),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: settings.bypassLan,
                      onChanged: isDirect
                          ? null
                          : (v) =>
                              _save(context, settings.copyWith(bypassLan: v)),
                      title: Text(l.bypassLan),
                      subtitle: Text(l.bypassLanDesc),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: settings.blockAds,
                      onChanged: isDirect
                          ? null
                          : (v) =>
                              _save(context, settings.copyWith(blockAds: v)),
                      title: Text(l.blockAds),
                      subtitle: Text(l.blockAdsDesc),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
