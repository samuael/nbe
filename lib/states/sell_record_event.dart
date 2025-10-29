import 'package:nbe/libs.dart';

class TransactionEvent {}

class LoadTransactions extends TransactionEvent {
  PriceRecordsLoaded loadRecords;
  LoadTransactions(this.loadRecords);
}

class UpdateTransactionEvent extends TransactionEvent {
  Transaction transaction;
  UpdateTransactionEvent(this.transaction);
}

class SaveTransactionEvent extends TransactionEvent {
  Transaction transaction;
  bool isUpdate;
  SaveTransactionEvent(this.transaction, {this.isUpdate = false});
}

class GetSeeTransactionsEvent extends TransactionEvent {}

class DeleteTransactionsEvent extends TransactionEvent {
  Set<String> ids;
  DeleteTransactionsEvent(this.ids);
}
