import 'package:nbe/libs.dart';

class SettingsEvent {}

class SettingsLoadEvent extends SettingsEvent {}

// ------------------ Single Setting Events ---------------

class SingleSettingEvent {}

class LoadLastSettingEvent extends SingleSettingEvent {}

class UpdateSettingEvent extends SingleSettingEvent {
  Setting setting;
  UpdateSettingEvent(this.setting);
}

class SelectSettingByIDEvent extends SingleSettingEvent {
  String settingID;
  SelectSettingByIDEvent(this.settingID);
}
