import 'package:nbe/libs.dart';

class SellRecordEvent {}

class SellRecordLoad extends SellRecordEvent {}

class UpdateRecordEvent extends SellRecordEvent {
  SellRecord record;
  UpdateRecordEvent(this.record);
}
