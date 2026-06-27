import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/common.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../connection/presentation/cubit/connection_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/proxy_node.dart';
import '../cubit/nodes_cubit.dart';

class ServersPage extends StatelessWidget {
  const ServersPage({super.key});

  Future<void> _importFromClipboard(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final messenger = context.read<NodesCubit>();
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    if (text.trim().isEmpty) {
      if (context.mounted) showSnack(context, l.nothingParsed);
      return;
    }
    final added = await messenger.addFromText(text);
    if (!context.mounted) return;
    showSnack(context, added > 0 ? l.serversAdded(added) : l.nothingParsed);
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final text = await showDialog<String>(
      context: context,
      builder: (_) => _TextPromptDialog(
        title: l.addFromLink,
        confirmLabel: l.add,
        hint: l.pasteLinkHint,
        minLines: 4,
        maxLines: 10,
        width: 460,
      ),
    );
    if (text == null || text.trim().isEmpty) return;
    if (!context.mounted) return;
    final added = await context.read<NodesCubit>().addFromText(text);
    if (!context.mounted) return;
    showSnack(context, added > 0 ? l.serversAdded(added) : l.nothingParsed);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      title: l.navServers,
      scrollable: false,
      actions: [
        BlocBuilder<NodesCubit, NodesState>(
          buildWhen: (a, b) => a.pinging != b.pinging,
          builder: (context, state) => OutlinedButton.icon(
            onPressed:
                state.pinging ? null : () => context.read<NodesCubit>().pingAll(),
            icon: state.pinging
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.speed, size: 18),
            label: Text(l.pingAll),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _importFromClipboard(context),
          icon: const Icon(Icons.content_paste, size: 18),
          label: Text(l.importFromClipboard),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => _showAddDialog(context),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l.addServer),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (a, b) =>
            a.settings.selectedNodeId != b.settings.selectedNodeId,
        builder: (context, settingsState) {
          final selectedId = settingsState.settings.selectedNodeId;
          return BlocBuilder<NodesCubit, NodesState>(
            builder: (context, state) {
              if (state.nodes.isEmpty) {
                return _EmptyState(message: l.noServers);
              }
              return ListView.separated(
                itemCount: state.nodes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final node = state.nodes[i];
                  return _NodeCard(
                    node: node,
                    latency: state.latencies[node.id],
                    selected: node.id == selectedId,
                    onSelect: () => _selectNode(context, node),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _selectNode(BuildContext context, ProxyNode node) async {
    await context.read<SettingsCubit>().selectNode(node.id);
    if (!context.mounted) return;
    await context.read<ConnectionCubit>().reconnectIfActive();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dns_outlined, size: 64, color: scheme.outline),
          const SizedBox(height: 16),
          SizedBox(
            width: 360,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.node,
    required this.latency,
    required this.selected,
    required this.onSelect,
  });

  final ProxyNode node;
  final int? latency;
  final bool selected;
  final VoidCallback onSelect;

  Future<void> _rename(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _TextPromptDialog(
        title: l.renameServer,
        confirmLabel: l.save,
        hint: node.displayServer,
        initialValue: node.name,
        width: 360,
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    if (!context.mounted) return;
    await context.read<NodesCubit>().rename(node.id, name.trim());
  }

  Future<void> _delete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDeleteTitle),
        content: Text(l.confirmDeleteNode(node.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await context.read<NodesCubit>().delete(node.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 1.6,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected ? scheme.primary : scheme.outline,
                size: 22,
              ),
              const SizedBox(width: 14),
              _ProtocolBadge(label: node.protocol.label),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      node.displayServer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _LatencyIndicator(latency: latency),
              PopupMenuButton<String>(
                tooltip: '',
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'ping':
                      context.read<NodesCubit>().ping(node.id);
                    case 'rename':
                      _rename(context);
                    case 'delete':
                      _delete(context);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'ping',
                    child: Row(
                      children: [
                        const Icon(Icons.speed, size: 18),
                        const SizedBox(width: 10),
                        Text(l.testLatency),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 10),
                        Text(l.renameServer),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: scheme.error),
                        const SizedBox(width: 10),
                        Text(l.deleteServer,
                            style: TextStyle(color: scheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProtocolBadge extends StatelessWidget {
  const _ProtocolBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: scheme.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _LatencyIndicator extends StatelessWidget {
  const _LatencyIndicator({required this.latency});
  final int? latency;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final color = latencyColor(latency, scheme);
    final String text;
    if (latency == null) {
      text = l.untested;
    } else if (latency! < 0) {
      text = l.timeout;
    } else {
      text = l.ms(latency!);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Reusable text-input dialog that owns its controller (disposed with the
/// dialog route). Returns the entered text via Navigator.pop, or null on cancel.
class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.confirmLabel,
    this.hint,
    this.initialValue = '',
    this.minLines = 1,
    this.maxLines = 1,
    this.width = 360,
  });

  final String title;
  final String confirmLabel;
  final String? hint;
  final String initialValue;
  final int minLines;
  final int maxLines;
  final double width;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final singleLine = widget.maxLines == 1;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: widget.width,
        child: TextField(
          controller: _controller,
          autofocus: true,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          textInputAction:
              singleLine ? TextInputAction.done : TextInputAction.newline,
          onSubmitted: singleLine ? (_) => _confirm() : null,
          decoration: InputDecoration(hintText: widget.hint),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
