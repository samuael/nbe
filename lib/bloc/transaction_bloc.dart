import 'package:nbe/libs.dart';

class SellRecordBloc extends Bloc<SellRecordEvent, TransactionState> {
  final TransactionsLocalProvider provider;
  SellRecordBloc(this.provider) : super(TransactionInit()) {
    on<SellRecordLoad>(
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
            result.forEach((el) {
              records.putIfAbsent(el.id, () {
                return el;
              });
            });
            emit(TransactionLoaded(records));
          } else {
            emit(TransactionLoaded({for (var obj in result) obj.id: obj}));
          }
        }
      },
    );
  }
}
