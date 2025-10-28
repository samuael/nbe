import 'package:nbe/libs.dart';

class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class UpdateTransactionEvent extends TransactionEvent {
  Transaction record;
  UpdateTransactionEvent(this.record);
}

class SaveTransactionEvent extends TransactionEvent {
  Transaction transaction;
  SaveTransactionEvent(this.transaction);
}

class GetSeeTransactionsEvent extends TransactionEvent {}

class DeleteTransactionsEvent extends TransactionEvent {
  Set<String> ids;
  DeleteTransactionsEvent(this.ids);
}
