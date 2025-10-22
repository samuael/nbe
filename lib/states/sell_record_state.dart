import 'package:nbe/libs.dart';

class TransactionState {}

class TransactionInit extends TransactionState {}

class TransactionLoaded extends TransactionState {
  Map<String, Transaction> records;

  TransactionLoaded(this.records);
}
