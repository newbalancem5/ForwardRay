import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves and owns the on-disk locations the app uses (config, cache, data
/// files, the installed core binary).
class AppPaths {
  AppPaths._(this.baseDir);

  final Directory baseDir;

  static Future<AppPaths> init() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'forwardray'));
    _ensure(dir);
    final paths = AppPaths._(dir);
    _ensure(Directory(paths.cacheDir));
    _ensure(Directory(paths.binDir));
    return paths;
  }

  static void _ensure(Directory d) {
    if (!d.existsSync()) d.createSync(recursive: true);
  }

  String get cacheDir => p.join(baseDir.path, 'cache');
  String get binDir => p.join(baseDir.path, 'bin');
  String get configPath => p.join(baseDir.path, 'config.json');
  String get logPath => p.join(baseDir.path, 'core.log');

  File file(String name) => File(p.join(baseDir.path, name));

  String get coreBinaryName => Platform.isWindows ? 'sing-box.exe' : 'sing-box';
  String get installedBinaryPath => p.join(binDir, coreBinaryName);
}
