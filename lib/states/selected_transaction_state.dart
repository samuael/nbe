import 'package:nbe/libs.dart';

class SelectedTransactionState {}

class SelectedTransactionInit extends SelectedTransactionState {}

class TransactionSelected extends SelectedTransactionState {
  Transaction transaction;
  TransactionSelected(this.transaction);
}
