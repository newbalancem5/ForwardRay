import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/common.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../connection/presentation/cubit/connection_cubit.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      title: l.navSettings,
      scrollable: true,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settings = state.settings;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _appearanceCard(context, l, settings),
              const SizedBox(height: 16),
              _generalCard(context, l, settings),
              const SizedBox(height: 16),
              _networkCard(context, l, settings),
              const SizedBox(height: 16),
              _coreCard(context, l),
              const SizedBox(height: 16),
              _aboutCard(context, l),
            ],
          );
        },
      ),
    );
  }

  // 1) Appearance
  Widget _appearanceCard(
      BuildContext context, AppLocalizations l, AppSettings settings) {
    final cubit = context.read<SettingsCubit>();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(l.settingsAppearance),
          const SizedBox(height: 4),
          _row(
            label: l.theme,
            trailing: DropdownButton<String>(
              value: settings.themeModeName,
              underline: const SizedBox.shrink(),
              onChanged: (v) {
                if (v != null) cubit.setThemeMode(v);
              },
              items: [
                DropdownMenuItem(value: 'system', child: Text(l.themeSystem)),
                DropdownMenuItem(value: 'light', child: Text(l.themeLight)),
                DropdownMenuItem(value: 'dark', child: Text(l.themeDark)),
              ],
            ),
          ),
          const Divider(height: 24),
          _row(
            label: l.language,
            trailing: DropdownButton<String?>(
              value: settings.languageCode,
              underline: const SizedBox.shrink(),
              onChanged: (v) => cubit.setLanguage(v),
              items: [
                DropdownMenuItem<String?>(
                    value: null, child: Text(l.languageSystem)),
                const DropdownMenuItem<String?>(
                    value: 'en', child: Text('English')),
                const DropdownMenuItem<String?>(
                    value: 'ru', child: Text('Русский')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2) General
  Widget _generalCard(
      BuildContext context, AppLocalizations l, AppSettings settings) {
    final cubit = context.read<SettingsCubit>();
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: FieldLabel(l.settingsGeneral),
          ),
          SwitchListTile(
            title: Text(l.minimizeToTray),
            subtitle: Text(l.minimizeToTrayDesc),
            value: settings.minimizeToTray,
            onChanged: (v) => cubit.save(settings.copyWith(minimizeToTray: v)),
          ),
          SwitchListTile(
            title: Text(l.launchAtStartup),
            value: settings.launchAtStartup,
            onChanged: (v) => cubit.save(settings.copyWith(launchAtStartup: v)),
          ),
          SwitchListTile(
            title: Text(l.autoConnect),
            value: settings.autoConnectOnStart,
            onChanged: (v) =>
                cubit.save(settings.copyWith(autoConnectOnStart: v)),
          ),
        ],
      ),
    );
  }

  // 3) Network
  Widget _networkCard(
      BuildContext context, AppLocalizations l, AppSettings settings) {
    final cubit = context.read<SettingsCubit>();
    Future<void> applyAndReconnect(AppSettings next) async {
      await cubit.save(next);
      if (context.mounted) {
        await context.read<ConnectionCubit>().reconnectIfActive();
      }
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(l.settingsNetwork),
          const SizedBox(height: 8),
          _PortField(
            label: l.localPort,
            initialValue: settings.localPort,
            onSubmitted: (value) =>
                applyAndReconnect(settings.copyWith(localPort: value)),
          ),
          const SizedBox(height: 12),
          _PortField(
            label: l.clashApiPort,
            initialValue: settings.clashApiPort,
            onSubmitted: (value) =>
                applyAndReconnect(settings.copyWith(clashApiPort: value)),
          ),
        ],
      ),
    );
  }

  // 4) Core
  Widget _coreCard(BuildContext context, AppLocalizations l) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(l.settingsCore),
          const SizedBox(height: 8),
          BlocBuilder<ConnectionCubit, ConnectionUiState>(
            buildWhen: (a, b) => a.coreInstalled != b.coreInstalled,
            builder: (context, state) {
              final ok = state.coreInstalled;
              return Row(
                children: [
                  Icon(
                    ok ? Icons.check_circle : Icons.error_outline,
                    color: ok
                        ? const Color(0xFF2BBF6A)
                        : const Color(0xFFE0A100),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(ok ? l.coreInstalled : l.coreNotInstalled),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<ConnectionCubit, ConnectionUiState>(
            buildWhen: (a, b) =>
                a.coreDownloading != b.coreDownloading ||
                a.coreDownloadProgress != b.coreDownloadProgress,
            builder: (context, state) {
              if (state.coreDownloading) {
                final pct = (state.coreDownloadProgress * 100)
                    .clamp(0, 100)
                    .toStringAsFixed(0);
                return Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text('${l.downloadingCore} $pct%'),
                  ],
                );
              }
              return Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.read<ConnectionCubit>().downloadCore(),
                  icon: const Icon(Icons.download, size: 18),
                  label: Text(l.downloadCore),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const _CoreInstaller(),
        ],
      ),
    );
  }

  // 5) About
  Widget _aboutCard(BuildContext context, AppLocalizations l) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5B6CFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ForwardRay',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                l.version('1.0.0'),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row({required String label, required Widget trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        trailing,
      ],
    );
  }
}

/// Numeric port input that keeps its own controller so the cursor is preserved
/// across rebuilds. Commits on submit / editing complete.
class _PortField extends StatefulWidget {
  const _PortField({
    required this.label,
    required this.initialValue,
    required this.onSubmitted,
  });

  final String label;
  final int initialValue;
  final ValueChanged<int> onSubmitted;

  @override
  State<_PortField> createState() => _PortFieldState();
}

class _PortFieldState extends State<_PortField> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.initialValue}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final value = int.tryParse(_controller.text.trim());
    if (value != null && value > 0 && value <= 65535) {
      widget.onSubmitted(value);
    } else {
      _controller.text = '${widget.initialValue}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (_) => _commit(),
      onEditingComplete: _commit,
    );
  }
}

/// Path field + install button for placing a sing-box binary.
class _CoreInstaller extends StatefulWidget {
  const _CoreInstaller();

  @override
  State<_CoreInstaller> createState() => _CoreInstallerState();
}

class _CoreInstallerState extends State<_CoreInstaller> {
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _install() async {
    final path = _controller.text.trim();
    if (path.isEmpty) return;
    final l = AppLocalizations.of(context);
    final connection = context.read<ConnectionCubit>();
    setState(() => _busy = true);
    try {
      await connection.installCore(path);
      await connection.checkCore();
      if (mounted) showSnack(context, l.coreInstalledOk);
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: '/path/to/sing-box',
              prefixIcon: Icon(Icons.folder_open),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: _busy ? null : _install,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.installCore),
        ),
      ],
    );
  }
}
