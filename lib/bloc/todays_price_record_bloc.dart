import 'dart:convert';

import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';

class TodaysPriceRecordBloc
    extends Bloc<TodayPriceRecordsEvent, TodayPriceRecordState> {
  final PriceNetworkRecordProvider networkProvider;
  final PriceRecordProvider provider;
  final StringDataProvider stringProvider;

  TodaysPriceRecordBloc(
      this.provider, this.networkProvider, this.stringProvider)
      : super(TodayPriceRecordsInit()) {
    on<LoadTodaysPriceRecordsEvent>((event, emit) async {
      if (state is TodayPriceRecordsLoaded &&
          (state as TodayPriceRecordsLoaded)
              .date
              .isAfter(DateTime.now().add(const Duration(hours: -1)))) {
        return;
      }
      var lastDate = DateTime.now();
      var dateInt = int.parse(DateFormat('yyyyMMdd').format(lastDate));
      try {
        var response = await getLastPriceRecordResponse();
        if (response != null &&
            response.data!.isNotEmpty &&
            int.parse(DateFormat('yyyyMMdd').format(response.data![0].date!)) ==
                dateInt) {
          emit(TodayPriceRecordsLoaded(response, lastDate));
          return;
        }
      } catch (e, a) {
        print(e.toString());
        print(a.toString());
      }

      for (int i = 0; i < 7; i++) {
        dateInt = int.parse(DateFormat('yyyyMMdd').format(lastDate));
        var response = await networkProvider.getPriceRecordByDate(dateInt);
        if (response.success == true && response.data!.isNotEmpty) {
          // save the last price record record to the database.
          print("Saved String: ${jsonEncode(response.toJson())}");
          stringProvider.insertStringPayload(StringPayload(
              StaticConstant.LAST_PRICE_RECORD_JSON,
              jsonEncode(response.toJson()),
              (DateTime.now().millisecondsSinceEpoch / 1000).toInt()));

          // emit the data.
          emit(TodayPriceRecordsLoaded(response, lastDate));
          return;
        } else if (response.success == true) {
          // if the response is a success but the data is not filled, meaning todays rate is not yet released.
          lastDate = lastDate.add(const Duration(days: -1));
          continue;
        } else {
          emit(TodayPriceRecordLoadFailed());
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
