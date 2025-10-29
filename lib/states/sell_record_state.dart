import 'package:nbe/libs.dart';

class TransactionState {}

class TransactionInit extends TransactionState {}

class TransactionLoaded extends TransactionState {
  Map<String, Transaction> records;
  double openSum;
  double openIncrease;
  TransactionLoaded(this.records, {this.openSum = 0, this.openIncrease = 0});

  TransactionLoaded clone() {
    return TransactionLoaded(records);
  }
}

class TransactionActionFailed extends TransactionState {
  String message;
  TransactionActionFailed(this.message);
}
