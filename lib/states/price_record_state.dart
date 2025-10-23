import 'package:nbe/types/types.dart';

class PriceRecordState {}

class PriceRecordsInit extends PriceRecordState {}

class PriceRecordsLoaded extends PriceRecordState {
  DateTime lastLoaded;
  List<PriceRecord> records;
  PriceRecordsLoaded(this.records, this.lastLoaded);
}

class PriceRecordsLoadFailed extends PriceRecordState {
  String reason;
  PriceRecordsLoadFailed(this.reason);
}

// ------------------------------------------------------------------

class TodayPriceRecordState {}

class TodayPriceRecordsLoaded extends TodayPriceRecordState {
  PriceRecordResponse response;
  DateTime date;
  TodayPriceRecordsLoaded(this.response, this.date);

  PriceRecord? getPriceRecordByGoldKarat(String karat) {
    for (var pr in response.data!) {
      if (pr.goldType!.karat == karat) {
        return pr;
      }
    }
    return null;
  }
}

class TodayPriceRecordsInit extends TodayPriceRecordState {}

class TodayPriceRecordLoadFailed extends TodayPriceRecordState {}

// ----------------------------------------

class SelectedDatePriceRecordState {}

class SelectedDatePriceRecordInit extends SelectedDatePriceRecordState {}

class SelectedDatePriceRecordLoaded extends SelectedDatePriceRecordState {
  PriceRecordResponse record;
  DateTime dateTime;
  SelectedDatePriceRecordLoaded(this.record, this.dateTime);
}

class SelectedDatePriceRecordLoadFailed extends SelectedDatePriceRecordState {
  SelectedDatePriceRecordLoadFailed();
}
