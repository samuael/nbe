import 'package:nbe/libs.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingLocalProvider provider;
  SettingsBloc(this.provider) : super(SettingsInit()) {
    on<SettingsLoadEvent>((event, emit) async {
      final result = await provider.getRecentSettings();
      emit(SettingsLoaded({for (var obj in result) obj.id: obj}));
    });
  }
}
