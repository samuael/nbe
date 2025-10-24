class PriceRecordEvent {}

class LoadPriceRecordsEvent extends PriceRecordEvent {}

class ShowTheLoadedEvent extends PriceRecordEvent {}

// ---------------------------------

class TodayPriceRecordsEvent {}

class LoadTodaysPriceRecordsEvent extends TodayPriceRecordsEvent {}

// -------------------------------

class SelectedDatePriceRecordEvent {}

class SelectOtherDatePriceRecordEvent extends SelectedDatePriceRecordEvent {
  DateTime dateTime;
  SelectOtherDatePriceRecordEvent(this.dateTime);
}
