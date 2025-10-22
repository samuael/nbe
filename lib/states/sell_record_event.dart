import 'package:nbe/libs.dart';

class SellRecordEvent {}

class SellRecordLoad extends SellRecordEvent {}

class UpdateRecordEvent extends SellRecordEvent {
  Transaction record;
  UpdateRecordEvent(this.record);
}
