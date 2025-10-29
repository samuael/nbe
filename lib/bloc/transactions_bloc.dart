import 'package:nbe/libs.dart';

class TransactionsBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionsLocalProvider provider;
  final SettingLocalProvider settingProvider;

  TransactionsBloc(this.provider, this.settingProvider)
      : super(TransactionInit()) {
    on<LoadTransactions>(
      (event, emit) async {
        int offset = 0;
        int limit = 0;
        if (state is TransactionLoaded) {
          offset = (state as TransactionLoaded).records.length;
          limit = offset + 10;
        }
        double sumAll = 0.0;
        double increaseAll = 0.0;
        final result = await provider.getRecentTransactions(offset, limit);
        if (result != null) {
          if (state is TransactionLoaded) {
            final records = (state as TransactionLoaded).records;
            for (var el in result) {
              records.putIfAbsent(el.id, () {
                return el;
              });
            }
            final Map<String, Setting> theSettings = {};
            for (var set in records.entries) {
              if (set.value.endDate!.isBefore(DateTime.now())) {
                set.value.isCompleted = true;
              } else {
                if (getATHPriceRecord(set.value.date, event.loadRecords,
                        endDate: set.value.endDate) !=
                    null) {
                  set.value.athPrice =
                      getATHPriceRecord(set.value.date, event.loadRecords)!
                          .priceBirr!;
                }
              }
              if (theSettings[set.key] == null) {
                theSettings[set.key] = (await settingProvider
                    .getSettingByID(set.value.settingID))!;
              }
              provider.insertTransaction(set.value);
              if (!set.value.isCompleted) {
                sumAll += set.value.getRemaining(theSettings[set.key]!);
                increaseAll += set.value.getIncreases(theSettings[set.key]!);
              }
            }
            emit(TransactionLoaded(records,
                openSum: sumAll, openIncrease: increaseAll));
          } else {
            final records = {for (var obj in result) obj.id: obj};
            final Map<String, Setting> theSettings = {};
            for (var set in records.entries) {
              if (set.value.endDate!.isBefore(DateTime.now())) {
                set.value.isCompleted = true;
              } else {
                if (getATHPriceRecord(set.value.date, event.loadRecords,
                        endDate: set.value.endDate) !=
                    null) {
                  set.value.athPrice =
                      getATHPriceRecord(set.value.date, event.loadRecords)!
                          .priceBirr!;
                }
              }
              if (theSettings[set.key] == null) {
                theSettings[set.key] = (await settingProvider
                    .getSettingByID(set.value.settingID))!;
              }
              provider.insertTransaction(set.value);
              if (!set.value.isCompleted) {
                sumAll += set.value.getRemaining(theSettings[set.key]!);
              }
            }

            emit(TransactionLoaded({for (var obj in result) obj.id: obj},
                openSum: sumAll, openIncrease: increaseAll));
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

  PriceRecord? getATHPriceRecord(DateTime date, PriceRecordsLoaded prLoaded,
      {DateTime? endDate}) {
    final dateTime = date;
    if (dateTime.isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
      return null;
    }
    final priceRecords = prLoaded.records;
    double highest = 0;
    PriceRecord? highestRecord;
    for (var pr in priceRecords) {
      final theDateTime = pr.date!;
      if ((theDateTime.isBefore(dateTime) || pr.priceBirr! <= highest) ||
          (endDate != null && endDate.isBefore(theDateTime))) {
        continue;
      }
      highest = pr.priceBirr!;
      highestRecord = pr;
    }
    return highestRecord;
  }
}
