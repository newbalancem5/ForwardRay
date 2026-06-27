import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local);
  final SettingsLocalDataSource _local;

  @override
  Future<AppSettings> load() => _local.read();

  @override
  Future<void> save(AppSettings settings) => _local.write(settings);
}
