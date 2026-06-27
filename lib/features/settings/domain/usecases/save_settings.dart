import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettings {
  const SaveSettings(this._repo);
  final SettingsRepository _repo;

  Future<void> call(AppSettings settings) => _repo.save(settings);
}
