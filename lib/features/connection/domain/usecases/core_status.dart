import '../repositories/connection_repository.dart';

class IsCoreInstalled {
  const IsCoreInstalled(this._repo);
  final ConnectionRepository _repo;

  Future<bool> call() => _repo.isCoreInstalled();
}

class InstallCore {
  const InstallCore(this._repo);
  final ConnectionRepository _repo;

  Future<void> call(String sourcePath) => _repo.installCore(sourcePath);
}

class DownloadCore {
  const DownloadCore(this._repo);
  final ConnectionRepository _repo;

  Future<void> call({void Function(double progress)? onProgress}) =>
      _repo.downloadCore(onProgress: onProgress);
}
