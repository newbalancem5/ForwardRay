import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/common.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../proxy/domain/entities/proxy_node.dart';
import '../../../proxy/presentation/cubit/nodes_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/connection_status.dart';
import '../cubit/connection_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      title: l.navHome,
      scrollable: true,
      child: BlocBuilder<ConnectionCubit, ConnectionUiState>(
        builder: (context, state) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(child: _ConnectButton(status: state.status)),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      state.status == ConnectionStatus.connected
                          ? l.tapToDisconnect
                          : l.tapToConnect,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!state.coreInstalled) ...[
                    _CoreSetupCard(state: state),
                    const SizedBox(height: 16),
                  ],
                  if (state.status == ConnectionStatus.error &&
                      state.error != null &&
                      state.error != 'CORE_NOT_FOUND')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ErrorBanner(message: _mapError(l, state.error!)),
                    ),
                  const _SelectedServerCard(),
                  const SizedBox(height: 16),
                  _TrafficGrid(state: state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _mapError(AppLocalizations l, String error) => switch (error) {
        'NO_NODE' => l.noServerSelected,
        'CORE_NOT_FOUND' => l.coreNotInstalled,
        _ => error,
      };
}

class _ConnectButton extends StatelessWidget {
  const _ConnectButton({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isConnected = status == ConnectionStatus.connected;
    final isConnecting = status == ConnectionStatus.connecting;

    final Color color = switch (status) {
      ConnectionStatus.connected => AppTheme.connectedColor,
      ConnectionStatus.connecting => AppTheme.seed,
      _ => AppTheme.seed.withValues(alpha: 0.85),
    };

    final label = switch (status) {
      ConnectionStatus.connected => l.statusConnected,
      ConnectionStatus.connecting => l.connecting,
      _ => l.statusDisconnected,
    };

    return Semantics(
      button: true,
      label: isConnected ? l.disconnect : l.connect,
      child: GestureDetector(
        onTap: isConnecting
            ? null
            : () => context.read<ConnectionCubit>().toggle(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isConnecting)
                const SizedBox(
                  width: 46,
                  height: 46,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else
                const Icon(Icons.power_settings_new,
                    size: 56, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedServerCard extends StatelessWidget {
  const _SelectedServerCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Rebuild when nodes or the selection (in settings) change.
    context.watch<NodesCubit>();
    context.watch<SettingsCubit>();
    final node = context.read<NodesCubit>().selectedNode;
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.dns, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.selectedServer,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  node?.name ?? l.noServerSelected,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                if (node != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    node.displayServer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (node != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                node.protocol.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrafficGrid extends StatelessWidget {
  const _TrafficGrid({required this.state});

  final ConnectionUiState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tiles = [
      StatTile(
        icon: Icons.arrow_upward,
        label: l.uploadSpeed,
        value: formatSpeed(state.traffic.up),
        color: const Color(0xFFE0593F),
      ),
      StatTile(
        icon: Icons.arrow_downward,
        label: l.downloadSpeed,
        value: formatSpeed(state.traffic.down),
        color: const Color(0xFF2BBF6A),
      ),
      StatTile(
        icon: Icons.upload,
        label: l.totalUp,
        value: formatBytes(state.totals.up),
      ),
      StatTile(
        icon: Icons.download,
        label: l.totalDown,
        value: formatBytes(state.totals.down),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCols = constraints.maxWidth < 560;
        final perRow = twoCols ? 2 : 4;
        const spacing = 12.0;
        const tileHeight = 84.0; // fixed so all tiles match, even with 2-line labels
        final itemWidth =
            (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final t in tiles)
              SizedBox(width: itemWidth, height: tileHeight, child: t),
          ],
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the sing-box core isn't installed: one-tap download with progress.
class _CoreSetupCard extends StatelessWidget {
  const _CoreSetupCard({required this.state});

  final ConnectionUiState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final downloading = state.coreDownloading;
    final pct = (state.coreDownloadProgress * 100).clamp(0, 100).toStringAsFixed(0);

    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.download_for_offline_outlined,
                color: scheme.onTertiaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  downloading ? l.downloadingCore : l.coreNotInstalled,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (downloading) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.coreDownloadProgress == 0
                          ? null
                          : state.coreDownloadProgress,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$pct%',
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!downloading)
            FilledButton.icon(
              onPressed: () => context.read<ConnectionCubit>().downloadCore(),
              icon: const Icon(Icons.download, size: 18),
              label: Text(l.downloadCore),
            ),
        ],
      ),
    );
  }
}
