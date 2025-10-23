import 'package:nbe/libs.dart';

class SelectedTransactionEvent {}

class SelectTransaction extends SelectedTransactionEvent {
  Transaction transaction;
  SelectTransaction(this.transaction);
}

class RemoveTransactionSelection extends SelectedTransactionEvent {}
