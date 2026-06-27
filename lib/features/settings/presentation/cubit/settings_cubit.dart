import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';

part 'settings_state.dart';

/// Single source of truth for [AppSettings].
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required GetSettings getSettings,
    required SaveSettings saveSettings,
  })  : _getSettings = getSettings,
        _saveSettings = saveSettings,
        super(const SettingsState(AppSettings()));

  final GetSettings _getSettings;
  final SaveSettings _saveSettings;

  Future<void> load() async {
    emit(SettingsState(await _getSettings()));
  }

  /// Persists and emits the new settings.
  Future<void> save(AppSettings next) async {
    await _saveSettings(next);
    emit(SettingsState(next));
  }

  AppSettings get settings => state.settings;

  Future<void> selectNode(String? id) =>
      save(settings.copyWith(selectedNodeId: id, clearSelectedNode: id == null));

  Future<void> setThemeMode(String name) =>
      save(settings.copyWith(themeModeName: name));

  Future<void> setLanguage(String? code) =>
      save(settings.copyWith(languageCode: code, clearLanguage: code == null));

  ThemeMode get themeMode => switch (settings.themeModeName) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Locale? get locale =>
      settings.languageCode == null ? null : Locale(settings.languageCode!);
}
