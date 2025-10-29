import 'dart:convert';

import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';

class SelectedDatePriceRecordBloc
    extends Bloc<SelectedDatePriceRecordEvent, SelectedDatePriceRecordState> {
  final PriceNetworkRecordProvider networkProvider;
  final PriceRecordProvider provider;
  final StringDataProvider stringProvider;

  final dateFormat = DateFormat('yyyyMMdd');

  SelectedDatePriceRecordBloc(
      this.provider, this.networkProvider, this.stringProvider)
      : super(SelectedDatePriceRecordInit()) {
    on<SelectOtherDatePriceRecordEvent>((event, emit) async {
      if (state is SelectedDatePriceRecordLoaded &&
          dateFormat
                  .format((state as SelectedDatePriceRecordLoaded).dateTime) ==
              dateFormat.format(event.dateTime)) {
        return;
      }

      var lastDate = event.dateTime;

      print("dateFormat.format(lastDate): ${dateFormat.format(lastDate)}\n\n");

      var dateInt = int.parse(dateFormat.format(lastDate));
      try {
        var response = await getLastPriceRecordResponse();
        if (response != null &&
            response.data!.isNotEmpty &&
            int.parse(dateFormat.format(response.data![0].date!)) == dateInt) {
          emit(SelectedDatePriceRecordLoaded(response, event.dateTime));
          return;
        }
      } catch (e, a) {
        print(e.toString());
        print(a.toString());
      }

      for (int i = 0; i < 7; i++) {
        dateInt = int.parse(dateFormat.format(lastDate));
        var response = await networkProvider.getPriceRecordByDate(dateInt);
        if (response.success == true && response.data!.isNotEmpty) {
          // emit the data
          emit(SelectedDatePriceRecordLoaded(response, lastDate));
          return;
        } else if (response.success == true) {
          // if the response is a success but the data is not filled, meaning todays rate is not yet released.
          lastDate = lastDate.subtract(const Duration(days: 1));
          continue;
        } else {
          emit(SelectedDatePriceRecordLoadFailed());
          return;
        }
      }
    });
  }

  Future<PriceRecordResponse?> getLastPriceRecordResponse() async {
    final result = await stringProvider
        .getStringPayloadByID(StaticConstant.LAST_PRICE_RECORD_JSON);
    if (result != null) {
      return PriceRecordResponse.fromJson(jsonDecode(result.payload));
    }
    return null;
  }
}
