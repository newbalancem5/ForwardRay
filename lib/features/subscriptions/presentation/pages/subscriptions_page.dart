import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/common.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/subscription.dart';
import '../cubit/subscriptions_cubit.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocListener<SubscriptionsCubit, SubscriptionsState>(
      listenWhen: (prev, curr) => curr.error != null && prev.error != curr.error,
      listener: (context, state) {
        showSnack(context, l.updateFailed(state.error!));
      },
      child: PageScaffold(
        title: l.navSubscriptions,
        scrollable: false,
        actions: [
          OutlinedButton.icon(
            onPressed: () => context.read<SubscriptionsCubit>().updateAll(),
            icon: const Icon(Icons.refresh),
            label: Text(l.updateAll),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l.addSubscription),
          ),
        ],
        child: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
          builder: (context, state) {
            if (state.subscriptions.isEmpty) {
              return _EmptyState(message: l.noSubscriptions);
            }
            return ListView.separated(
              itemCount: state.subscriptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sub = state.subscriptions[index];
                return _SubscriptionCard(
                  subscription: sub,
                  updating: state.updating.contains(sub.id),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final cubit = context.read<SubscriptionsCubit>();
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _AddSubscriptionDialog(),
      ),
    );
  }
}

/// Owns its text controllers so their lifecycle matches the dialog route
/// (disposed only after the close animation finishes).
class _AddSubscriptionDialog extends StatefulWidget {
  const _AddSubscriptionDialog();

  @override
  State<_AddSubscriptionDialog> createState() => _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends State<_AddSubscriptionDialog> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    context.read<SubscriptionsCubit>().add(name.isEmpty ? url : name, url);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.addSubscription),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.subscriptionName),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(labelText: l.subscriptionUrl),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.add)),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscription, required this.updating});

  final Subscription subscription;
  final bool updating;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final date = subscription.lastUpdated == null
        ? l.never
        : _formatDate(subscription.lastUpdated!);

    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.rss_feed, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subscription.url,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _MetaChip(
                      icon: Icons.dns_outlined,
                      label: l.nodesCount(subscription.nodeCount),
                    ),
                    _MetaChip(
                      icon: Icons.schedule,
                      label: l.lastUpdated(date),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (updating)
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else ...[
            IconButton(
              tooltip: l.update,
              onPressed: () =>
                  context.read<SubscriptionsCubit>().update(subscription.id),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: l.delete,
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final cubit = context.read<SubscriptionsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.confirmDeleteTitle),
        content: Text(l.confirmDeleteSub(subscription.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cubit.delete(subscription.id);
    }
  }

  static String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rss_feed_outlined, size: 64, color: muted),
          const SizedBox(height: 16),
          SizedBox(
            width: 360,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}
