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
}

class TodayPriceRecordsInit extends TodayPriceRecordState {}

class TodayPriceRecordLoadFailed extends TodayPriceRecordState {}
