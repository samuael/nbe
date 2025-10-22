import 'package:nbe/libs.dart';

class SettingsState {}

class SettingsInit extends SettingsState {}

class SettingsLoaded extends SettingsState {
  Map<String, Setting> settings;
  SettingsLoaded(this.settings);
}

class SettingsLoadFailed extends SettingsState {}

// ------------------- Last Single Setting States ----------------

class SettingState {}

class SettingInit extends SettingState {}

class SettingLoadFailed extends SettingState {
  String message;
  SettingLoadFailed(this.message);
}

class SettingLoaded extends SettingState {
  Setting setting;
  SettingLoaded(this.setting);
}
