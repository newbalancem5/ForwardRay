import 'dart:async';
import 'dart:io';

import '../../../../core/storage/app_paths.dart';

/// Manages the lifecycle of the bundled/installed `sing-box` core process.
class SingBoxProcess {
  SingBoxProcess(this._paths);

  final AppPaths _paths;
  Process? _process;
  final _logController = StreamController<String>.broadcast();

  bool get isRunning => _process != null;
  Stream<String> get logs => _logController.stream;

  /// Finds a usable sing-box binary: installed copy first, then PATH.
  Future<String?> resolveBinary() async {
    final installed = File(_paths.installedBinaryPath);
    if (installed.existsSync()) return installed.path;
    try {
      final which = Platform.isWindows ? 'where' : 'which';
      final res = await Process.run(which, ['sing-box']);
      if (res.exitCode == 0) {
        final path = (res.stdout as String).trim().split('\n').first.trim();
        if (path.isNotEmpty) return path;
      }
    } catch (_) {}
    return null;
  }

  Future<void> installBinary(String sourcePath) async {
    final dir = Directory(_paths.binDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final dest = await File(sourcePath).copy(_paths.installedBinaryPath);
    if (!Platform.isWindows) {
      await Process.run('chmod', ['755', dest.path]);
    }
  }

  /// Validates the written config. Returns null on success, else the error text.
  Future<String?> checkConfig(String binary) async {
    final res = await Process.run(
      binary,
      ['check', '-c', _paths.configPath],
      workingDirectory: _paths.cacheDir,
    );
    if (res.exitCode == 0) return null;
    final err = res.stderr as String;
    return err.isNotEmpty ? err : res.stdout as String;
  }

  /// Starts the core. Returns null on success, or an error message.
  Future<String?> start() async {
    if (_process != null) return null;

    final binary = await resolveBinary();
    if (binary == null) return 'CORE_NOT_FOUND';

    final checkErr = await checkConfig(binary);
    if (checkErr != null) return 'CONFIG_INVALID:$checkErr';

    try {
      _process = await Process.start(
        binary,
        ['run', '-c', _paths.configPath],
        workingDirectory: _paths.cacheDir,
      );
    } catch (e) {
      return 'START_FAILED:$e';
    }

    final log = File(_paths.logPath).openWrite(mode: FileMode.write);
    void pipe(Stream<List<int>> s) =>
        s.transform(const SystemEncoding().decoder).listen((data) {
          log.write(data);
          _logController.add(data);
        });
    pipe(_process!.stdout);
    pipe(_process!.stderr);
    _process!.exitCode.then((code) {
      log.close();
      _logController.add('\n[core exited: $code]\n');
      _process = null;
    });
    return null;
  }

  Future<void> stop() async {
    final proc = _process;
    _process = null;
    if (proc == null) return;
    proc.kill(ProcessSignal.sigterm);
    await Future.any([
      proc.exitCode,
      Future.delayed(const Duration(seconds: 3)),
    ]);
    proc.kill(ProcessSignal.sigkill);
  }

  void dispose() => _logController.close();
}
