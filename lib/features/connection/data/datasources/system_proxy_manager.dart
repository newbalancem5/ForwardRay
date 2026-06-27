import 'dart:ffi';
import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

/// Sets and clears the OS-level HTTP/SOCKS proxy.
class SystemProxyManager {
  const SystemProxyManager();

  static const _bypass = [
    '127.0.0.1',
    'localhost',
    '*.local',
    '10.*',
    '172.16.*',
    '192.168.*',
    '<local>',
  ];

  Future<void> enable(int port) async {
    if (Platform.isMacOS) {
      await _macSet(port);
    } else if (Platform.isWindows) {
      _windowsSet('127.0.0.1:$port');
    }
  }

  Future<void> disable() async {
    if (Platform.isMacOS) {
      await _macClear();
    } else if (Platform.isWindows) {
      _windowsClear();
    }
  }

  // --- macOS: networksetup ---
  Future<List<String>> _macServices() async {
    final res = await Process.run('networksetup', ['-listallnetworkservices']);
    final lines = (res.stdout as String).split('\n');
    return lines
        .skip(1) // informational header
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('*')) // * = disabled
        .toList();
  }

  Future<void> _macSet(int port) async {
    for (final s in await _macServices()) {
      await Process.run('networksetup', ['-setwebproxy', s, '127.0.0.1', '$port']);
      await Process.run(
          'networksetup', ['-setsecurewebproxy', s, '127.0.0.1', '$port']);
      await Process.run(
          'networksetup', ['-setsocksfirewallproxy', s, '127.0.0.1', '$port']);
      await Process.run('networksetup', ['-setwebproxystate', s, 'on']);
      await Process.run('networksetup', ['-setsecurewebproxystate', s, 'on']);
      await Process.run('networksetup', ['-setsocksfirewallproxystate', s, 'on']);
      await Process.run('networksetup', ['-setproxybypassdomains', s, ..._bypass]);
    }
  }

  Future<void> _macClear() async {
    for (final s in await _macServices()) {
      await Process.run('networksetup', ['-setwebproxystate', s, 'off']);
      await Process.run('networksetup', ['-setsecurewebproxystate', s, 'off']);
      await Process.run('networksetup', ['-setsocksfirewallproxystate', s, 'off']);
    }
  }

  // --- Windows: WinINET registry + refresh ---
  void _windowsSet(String server) {
    final key = Registry.openPath(
      RegistryHive.currentUser,
      path: r'Software\Microsoft\Windows\CurrentVersion\Internet Settings',
      desiredAccessRights: AccessRights.allAccess,
    );
    key.createValue(const RegistryValue.int32('ProxyEnable', 1));
    key.createValue(RegistryValue.string('ProxyServer', server));
    key.createValue(RegistryValue.string('ProxyOverride', _bypass.join(';')));
    key.close();
    _windowsRefresh();
  }

  void _windowsClear() {
    final key = Registry.openPath(
      RegistryHive.currentUser,
      path: r'Software\Microsoft\Windows\CurrentVersion\Internet Settings',
      desiredAccessRights: AccessRights.allAccess,
    );
    key.createValue(const RegistryValue.int32('ProxyEnable', 0));
    key.close();
    _windowsRefresh();
  }

  void _windowsRefresh() {
    if (!Platform.isWindows) return;
    try {
      final wininet = DynamicLibrary.open('wininet.dll');
      final internetSetOption = wininet.lookupFunction<
          Int32 Function(IntPtr, Uint32, Pointer, Uint32),
          int Function(int, int, Pointer, int)>('InternetSetOptionW');
      const internetOptionSettingsChanged = 39;
      const internetOptionRefresh = 37;
      internetSetOption(0, internetOptionSettingsChanged, nullptr, 0);
      internetSetOption(0, internetOptionRefresh, nullptr, 0);
    } catch (_) {}
  }
}
