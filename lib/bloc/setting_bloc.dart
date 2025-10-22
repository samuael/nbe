import 'package:nbe/libs.dart';

class SettingBloc extends Bloc<SingleSettingEvent, SettingState> {
  final SettingLocalProvider provider;
  final StringDataProvider stringProvider;

  SettingBloc(this.provider, this.stringProvider) : super(SettingInit()) {
    on<LoadLastSettingEvent>((event, emit) async {
      if (state is SettingLoaded) {
        return;
      }
      final stringPayload = await stringProvider
          .getStringPayloadByID(StaticConstant.LAST_SETTING_ID);

      final setting = await provider.getSettingByID(stringPayload!.payload);

      if (setting == null) {
        emit(SettingLoadFailed("unable to find the recent setting"));
        return;
      }
      emit(SettingLoaded(setting));
    });

    on<UpdateSettingEvent>((event, emit) async {
      if (state is! SettingLoaded) {
        final newSetting = await provider.getSettingByDetail(event.setting);
        if (newSetting != null) {
          emit(SettingLoaded(newSetting));
          return;
        }

        final count = await provider.insertSetting(event.setting);
        if (count == 0) {
          emit(SettingLoadFailed("setting update failed"));
          return;
        }
        emit(SettingLoaded(event.setting));
        await stringProvider.insertStringPayload(StringPayload(
            StaticConstant.LAST_SETTING_ID,
            event.setting.id,
            (DateTime.now().millisecondsSinceEpoch / 1000).toInt()));
        return;
      }
      final currentSetting = (state as SettingLoaded);
      if (event.setting.bankFeePercentage ==
              currentSetting.setting.bankFeePercentage &&
          event.setting.taxPerGram == currentSetting.setting.taxPerGram &&
          event.setting.holdPercentage ==
              currentSetting.setting.holdPercentage) {
        return;
      }
    });

    on<SelectSettingByIDEvent>((event, emit) async {
      final setting = await provider.getSettingByID(event.settingID);
      if (setting != null) {
        emit(SettingLoaded(setting));
        return;
      }
      emit(SettingLoadFailed("setting by id ${event.settingID} not found"));
    });
  }
}
