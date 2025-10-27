import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';

// states

class DefaultNbeHoldDurationState {}

class DefaultNbeHoldDurationLoaded extends DefaultNbeHoldDurationState {
  int days;
  DefaultNbeHoldDurationLoaded(this.days);
}

// Events
class DefaultNbeHoldDurationEvent {}

class LoadDefaultNbeHoldDuration extends DefaultNbeHoldDurationEvent {}

class UpdateDefaultNBEHoldDuration extends DefaultNbeHoldDurationEvent {
  int days;
  UpdateDefaultNBEHoldDuration({required this.days});
}

class DefaultNbeHoldDurationBloc
    extends Bloc<DefaultNbeHoldDurationEvent, DefaultNbeHoldDurationState> {
  final StringDataProvider stringProvider;

  // generate dates
  DefaultNbeHoldDurationBloc(this.stringProvider)
      : super(DefaultNbeHoldDurationLoaded(30)) {
    on<LoadDefaultNbeHoldDuration>((event, emit) async {
      final payload = await stringProvider.getStringPayloadByID(222) ??
          StringPayload(222, "30", 0);
      final maxPriceRecords = int.tryParse(payload.payload) ?? 0;
      emit(DefaultNbeHoldDurationLoaded(maxPriceRecords));
      return;
    });

    on<UpdateDefaultNBEHoldDuration>((event, emit) async {
      final payload = await stringProvider
          .insertStringPayload(StringPayload(222, "${event.days}", 0));
      if (payload > 0) {
        emit(DefaultNbeHoldDurationLoaded(event.days));
        return;
      }
    });
  }
}
