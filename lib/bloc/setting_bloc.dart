import 'package:nbe/libs.dart';

class SettingBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingLocalProvider provider;
  SettingBloc(this.provider) : super(SettingsInit()) {
    on<SettingsLoadEvent>((event, emit) async {
      if (state is SettingsLoaded) {
        return;
      }
      
    });
  }
}
