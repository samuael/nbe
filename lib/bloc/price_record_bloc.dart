import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';

class PriceRecordBloc extends Bloc<PriceRecordEvent, PriceRecordState> {
  final PriceRecordProvider provider;
  final PriceNetworkRecordProvider networkProvider;
  final StringDataProvider stringProvider;

  final dateFormat = DateFormat('yyyyMMdd');

  // generate dates
  PriceRecordBloc(this.provider, this.networkProvider, this.stringProvider)
      : super(PriceRecordsInit()) {
    on<LoadPriceRecordsEvent>(
      (event, emit) async {
        if (state is PriceRecordsLoaded &&
            (state as PriceRecordsLoaded)
                .lastLoaded
                .isAfter(DateTime.now().subtract(const Duration(hours: 1)))) {
          return;
        }
        DateTime last = DateTime.now();
        final Set<int> priceRecords = {int.parse(dateFormat.format(last))};

        final payload = await stringProvider.getStringPayloadByID(222) ??
            StringPayload(222, "30", 0);
        final maxPriceRecords = int.tryParse(payload.payload) ?? 0 + 10;

        for (int i = 1; i < maxPriceRecords; i++) {
          last = last.subtract(const Duration(days: 1));
          priceRecords.add(int.parse(dateFormat.format(last)));
        }

        final savedPriceRecords = await provider.getPriceRecords();

        final Map<int, PriceRecord> foundPrices = {};
        final List<int> expiredPrices = [];

        for (int i = 0; i < savedPriceRecords.length; i++) {
          if (priceRecords.contains(
              int.parse(dateFormat.format(savedPriceRecords[i]!.date!)))) {
            foundPrices[
                    int.parse(dateFormat.format(savedPriceRecords[i]!.date!))] =
                savedPriceRecords[i]!;
            priceRecords.remove(
                int.parse(dateFormat.format(savedPriceRecords[i]!.date!)));
          } else {
            expiredPrices
                .add(int.parse(dateFormat.format(savedPriceRecords[i]!.date!)));
          }
        }

        try {
          Set<int> fetched = {};
          // load and check the missing dates.
          for (int i = 0; i < priceRecords.length; i++) {
            final response = await networkProvider
                .getPriceRecordByDate(priceRecords.toList()[i]);
            if (response.success == true) {
              final karat24Value = response.get24KaratRecord();
              if (karat24Value != null) {
                fetched.add(priceRecords.toList()[i]);
                foundPrices[int.parse(dateFormat.format(karat24Value.date!))] =
                    karat24Value;
                await provider.insertOrUpdatePriceRecord(karat24Value);
              }
            }
          }
          for (int l = 0; l < fetched.length; l++) {
            priceRecords.remove(fetched.elementAt(l));
          }
        } catch (e, a) {
          print(e.toString());
          print(a.toString());
          emit(PriceRecordsLoadFailed("loading prices was not succesful"));
          return;
        }
        final sortedFoundPrices = Map.fromEntries(
          foundPrices.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
        );
        emit(PriceRecordsLoaded(
            sortedFoundPrices.values.toList(), DateTime.now()));
      },
    );

    on<ShowTheLoadedEvent>((event, emit) async {
      final savedPriceRecords = await provider.getPriceRecords();
      for (int i = 0; i < savedPriceRecords.length; i++) {
        print(savedPriceRecords[i]!.date);
      }
    });
  }

  PriceRecord? getATHPriceRecord(DateTime date) {
    if (state is! PriceRecordsLoaded) {
      return null;
    }
    final dateTime = date;
    if (dateTime.isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
      return null;
    }
    final priceRecords = (state as PriceRecordsLoaded).records;
    double highest = 0;
    PriceRecord? highestRecord;
    for (var pr in priceRecords) {
      final theDateTime = pr.date!;
      if (theDateTime.isBefore(dateTime) || pr.priceBirr! <= highest) {
        continue;
      }
      highest = pr.priceBirr!;
      highestRecord = pr;
    }
    return highestRecord;
  }
}
