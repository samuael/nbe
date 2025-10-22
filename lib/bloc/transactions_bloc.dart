import 'package:nbe/libs.dart';

class TransactionBloc extends Bloc<SellRecordEvent, TransactionState> {
  final TransactionsLocalProvider provider;
  TransactionBloc(this.provider) : super(TransactionInit()) {
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

    // on<UpdateRecordEvent>((event, emit) {
    //   if (state is TransactionLoaded) {
    //     final dmap = (state as TransactionLoaded).records;
    //     dmap[event.record.id] = event.record;
    //     emit(TransactionLoaded(dmap));
    //   }
    // });
  }

  Future<bool> saveRecord(Transaction record) async {
    if (record.id == 0) {
      return false;
    }
    return provider.saveRecord(record);
  }
}
