import 'package:nbe/libs.dart';

class TransactionsBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionsLocalProvider provider;
  TransactionsBloc(this.provider) : super(TransactionInit()) {
    on<LoadTransactions>(
      (event, emit) async {
        int offset = 0;
        int limit = 0;
        if (state is TransactionLoaded) {
          offset = (state as TransactionLoaded).records.length;
          limit = offset + 10;
        }
        final result = await provider.getRecentTransactions(offset, limit);
        if (result != null) {
          if (state is TransactionLoaded) {
            final records = (state as TransactionLoaded).records;
            for (var el in result) {
              records.putIfAbsent(el.id, () {
                return el;
              });
            }
            emit(TransactionLoaded(records));
          } else {
            emit(TransactionLoaded({for (var obj in result) obj.id: obj}));
          }
        }
      },
    );

    on<GetSeeTransactionsEvent>((event, emit) async {
      final results = await provider.getRecentTransactions(0, 1000);
      print("GetSeeTransactionsEvent: ${results?.length}");
      for (var val in results!) {
        print("${val.date} ${val.gram} \n");
      }
    });

    on<DeleteTransactionsEvent>((event, emit) async {
      final results = await provider.deleteTransactionsByID(event.ids);
      if (results > 0) {
        (state as TransactionLoaded).records.removeWhere((key, tr) {
          return event.ids.contains(tr.id);
        });
        emit((state as TransactionLoaded).clone());
        return;
      }
    });

    on<SaveTransactionEvent>((event, emit) async {
      final result = await provider.insertTransaction(event.transaction);
      if (result == 0) {
        emit(TransactionActionFailed("insertion was not succesful"));
        return;
      }
      if (state is TransactionLoaded) {
        (state as TransactionLoaded).records[event.transaction.id] =
            event.transaction;
        emit((state as TransactionLoaded).clone());
        return;
      }
      emit(TransactionLoaded({event.transaction.id: event.transaction}));
    });
  }
}
