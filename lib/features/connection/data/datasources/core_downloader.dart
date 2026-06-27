import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/failure.dart';
import '../../../../core/storage/app_paths.dart';

/// Downloads the sing-box core for the current platform/arch from the official
/// SagerNet GitHub releases, extracts it and installs it into the app bin dir.
class CoreDownloader {
  CoreDownloader(this._paths);

  final AppPaths _paths;

  static const _repo = 'SagerNet/sing-box';

  /// Downloads sing-box [version] (e.g. "1.11.15"), reporting 0..1 progress.
  Future<void> download(String version, {void Function(double)? onProgress}) async {
    final asset = await _assetName(version);
    final url = 'https://github.com/$_repo/releases/download/v$version/$asset';
    final bytes = await _fetch(url, onProgress);
    final binary = _extractBinary(asset, bytes);
    if (binary == null || binary.isEmpty) {
      throw CoreStartFailure('sing-box binary not found in $asset');
    }
    await _install(binary);

    // Verify the binary survived (Windows Defender sometimes quarantines it).
    final file = File(_paths.installedBinaryPath);
    if (!file.existsSync() || await file.length() < 1000000) {
      throw const CoreStartFailure(
          'Core file missing after install — it may have been blocked by '
          'antivirus. Allow sing-box.exe and try again, or install manually.');
    }
  }

  Future<List<int>> _fetch(String url, void Function(double)? onProgress) async {
    final client = http.Client();
    try {
      final resp = await client.send(http.Request('GET', Uri.parse(url)));
      if (resp.statusCode != 200) {
        throw NetworkFailure('HTTP ${resp.statusCode}');
      }
      final total = resp.contentLength ?? 0;
      final bytes = <int>[];
      var received = 0;
      await for (final chunk in resp.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
      onProgress?.call(1);
      return bytes;
    } on Failure {
      rethrow;
    } catch (e) {
      throw NetworkFailure('$e');
    } finally {
      client.close();
    }
  }

  List<int>? _extractBinary(String asset, List<int> bytes) {
    final Archive archive;
    if (asset.endsWith('.zip')) {
      archive = ZipDecoder().decodeBytes(bytes);
    } else {
      final tar = GZipDecoder().decodeBytes(bytes);
      archive = TarDecoder().decodeBytes(tar);
    }
    ArchiveFile? largest;
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final base = file.name.replaceAll('\\', '/').split('/').last.toLowerCase();
      if (base == 'sing-box' || base == 'sing-box.exe') {
        return file.readBytes();
      }
      if (largest == null || file.size > largest.size) largest = file;
    }
    // Fallback: the core binary is by far the largest file in the archive.
    return largest?.readBytes();
  }

  Future<void> _install(List<int> binary) async {
    final dir = Directory(_paths.binDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File(_paths.installedBinaryPath);
    await file.writeAsBytes(binary, flush: true);
    if (!Platform.isWindows) {
      await Process.run('chmod', ['755', file.path]);
    }
  }

  Future<String> _assetName(String version) async {
    if (Platform.isMacOS) {
      return 'sing-box-$version-darwin-${await _unixArch()}.tar.gz';
    }
    if (Platform.isLinux) {
      return 'sing-box-$version-linux-${await _unixArch()}.tar.gz';
    }
    if (Platform.isWindows) {
      return 'sing-box-$version-windows-${_winArch()}.zip';
    }
    throw const CoreStartFailure('unsupported platform');
  }

  Future<String> _unixArch() async {
    try {
      final res = await Process.run('uname', ['-m']);
      final m = (res.stdout as String).trim().toLowerCase();
      if (m == 'arm64' || m == 'aarch64') return 'arm64';
      if (m.contains('armv7')) return 'armv7';
      return 'amd64';
    } catch (_) {
      return 'amd64';
    }
  }

  String _winArch() {
    final a = (Platform.environment['PROCESSOR_ARCHITECTURE'] ?? 'AMD64')
        .toUpperCase();
    return a.contains('ARM') ? 'arm64' : 'amd64';
  }
}
