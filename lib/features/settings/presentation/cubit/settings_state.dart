part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState(this.settings);
  final AppSettings settings;

  @override
  List<Object?> get props => [settings];
}
