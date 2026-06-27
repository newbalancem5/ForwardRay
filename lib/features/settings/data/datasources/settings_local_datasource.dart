import 'dart:convert';

import '../../../../core/storage/app_paths.dart';
import '../../domain/entities/app_settings.dart';
import '../models/app_settings_model.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._paths);
  final AppPaths _paths;

  Future<AppSettings> read() async {
    final file = _paths.file('settings.json');
    if (!file.existsSync()) return const AppSettings();
    try {
      final j = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return appSettingsFromJson(j);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> write(AppSettings settings) async {
    await _paths.file('settings.json').writeAsString(jsonEncode(settings.toJson()));
  }
}
