import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';

class TodaysPriceRecordBloc
    extends Bloc<TodayPriceRecordsEvent, TodayPriceRecordState> {
  final PriceNetworkRecordProvider networkProvider;

  TodaysPriceRecordBloc(this.networkProvider) : super(TodayPriceRecordsInit()) {
    on<LoadTodaysPriceRecordsEvent>((event, emit) async {
      if (state is TodayPriceRecordsLoaded &&
          (state as TodayPriceRecordsLoaded)
              .date
              .isBefore(DateTime.now().add(const Duration(hours: -1)))) {
        return;
      }
      final today = DateTime.now();
      final dateFormat = DateFormat('yyyy-MM-dd');
      final response =
          await networkProvider.getPriceRecordByDate(dateFormat.format(today));
      if (response.success ?? false) {
        emit(TodayPriceRecordsLoaded(response, today));
      } else {
        emit(TodayPriceRecordLoadFailed());
      }
    });
  }
}
