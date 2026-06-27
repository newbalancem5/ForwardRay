import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../core/theme/app_theme.dart';
import '../features/connection/domain/entities/connection_status.dart';
import '../features/connection/presentation/cubit/connection_cubit.dart';
import '../features/connection/presentation/pages/home_page.dart';
import '../features/proxy/presentation/pages/servers_page.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import '../features/settings/presentation/pages/routing_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/subscriptions/presentation/pages/subscriptions_page.dart';
import '../l10n/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with TrayListener, WindowListener {
  int _index = 0;

  static const _pages = [
    HomePage(),
    ServersPage(),
    SubscriptionsPage(),
    RoutingPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);
    _initTray();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  // Standard single tray icon (the app brand icon) for all platforms.
  String _trayIconPath() => Platform.isWindows ? 'assets/tray.ico' : 'assets/tray.png';

  Future<void> _initTray() async {
    await trayManager.setIcon(_trayIconPath());
    await _rebuildTrayMenu(context.read<ConnectionCubit>().isConnected);
  }

  Future<void> _rebuildTrayMenu(bool connected) async {
    final l = AppLocalizations.of(context);
    await trayManager.setToolTip('ForwardRay');
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(
        key: 'status',
        label: connected ? '● ${l.statusConnected}' : '○ ${l.statusDisconnected}',
        disabled: true,
      ),
      MenuItem.separator(),
      MenuItem(key: 'show', label: l.navHome),
      MenuItem(key: 'toggle', label: connected ? l.disconnect : l.connect),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: l.close),
    ]));
  }

  // --- Tray events ---
  @override
  void onTrayIconMouseDown() => _showWindow();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    final connection = context.read<ConnectionCubit>();
    switch (menuItem.key) {
      case 'show':
        await _showWindow();
      case 'toggle':
        await connection.toggle();
      case 'quit':
        await _quit();
    }
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _quit() async {
    await context.read<ConnectionCubit>().disconnect();
    await trayManager.destroy();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  // --- Window events ---
  @override
  void onWindowClose() async {
    final minimize = context.read<SettingsCubit>().settings.minimizeToTray;
    if (minimize) {
      await windowManager.hide();
    } else {
      await _quit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionCubit, ConnectionUiState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) =>
          _rebuildTrayMenu(state.status == ConnectionStatus.connected),
      child: Scaffold(
        body: Row(
          children: [
            _SideNav(index: _index, onSelect: (i) => setState(() => _index = i)),
            const VerticalDivider(width: 1),
            Expanded(child: IndexedStack(index: _index, children: _pages)),
          ],
        ),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final connected = context.select<ConnectionCubit, bool>((c) => c.isConnected);
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _BrandMark(connected: connected),
          const SizedBox(height: 12),
          Expanded(
            child: NavigationRail(
              backgroundColor: Colors.transparent,
              selectedIndex: index,
              onDestinationSelected: onSelect,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: Text(l.navHome),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.dns_outlined),
                  selectedIcon: const Icon(Icons.dns),
                  label: Text(l.navServers),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.rss_feed_outlined),
                  selectedIcon: const Icon(Icons.rss_feed),
                  label: Text(l.navSubscriptions),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.alt_route_outlined),
                  selectedIcon: const Icon(Icons.alt_route),
                  label: Text(l.navRouting),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(l.navSettings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand icon shown at the top of the side nav, with a connection status dot.
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              'assets/app_icon.png',
              width: 46,
              height: 46,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: connected
                    ? AppTheme.connectedColor
                    : const Color(0xFF9AA0AE),
                shape: BoxShape.circle,
                border: Border.all(color: bg, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
