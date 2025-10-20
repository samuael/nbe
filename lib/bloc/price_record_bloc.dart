import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';

class PriceRecordBloc extends Bloc<PriceRecordEvent, PriceRecordState> {
  final PriceRecordProvider provider;
  final PriceNetworkRecordProvider networkProvider;
  final StringDataProvider stringProvider;

  final dateFormat = DateFormat('yyyy-MM-dd');

// generate dates.
  PriceRecordBloc(this.provider, this.networkProvider, this.stringProvider)
      : super(PriceRecordsInit()) {
    on<LoadPriceRecordsEvent>(
      (event, emit) async {
        if (state is PriceRecordsLoaded &&
            (state as PriceRecordsLoaded)
                .lastLoaded
                .isBefore(DateTime.now().add(const Duration(hours: -1)))) {
          return;
        }
        DateTime last = DateTime.now();
        final priceRecords = [dateFormat.format(last)];

        final payload = await stringProvider.getStringPayloadByID(222) ??
            StringPayload(222, "30", 0);
        final maxPriceRecords = int.tryParse(payload.payload) ?? 0;

        for (int i = 1; i < maxPriceRecords; i++) {
          last = last.add(const Duration(days: -1));
          priceRecords.add(dateFormat.format(last));
        }

        final savedPriceRecords = await provider.getPriceRecords();

        final List<PriceRecord> foundPrices = [];
        final List<String> expiredPrices = [];

        for (int i = 0; i < savedPriceRecords.length; i++) {
          if (priceRecords.contains(savedPriceRecords[i]!.date)) {
            foundPrices.add(savedPriceRecords[i]!);
          } else {
            expiredPrices.add(savedPriceRecords[i]!.date!);
          }
        }

        final success = await provider.deletePriceRecordsByID(expiredPrices);
        if (!success) {
          emit(PriceRecordsLoadFailed("deleting records was not succesful"));
          return;
        }

        for (int j = 0; j < foundPrices.length; j++) {
          if (priceRecords.contains(foundPrices[j].date)) {
            priceRecords.remove(foundPrices[j].date);
          }
        }

        try {
          // load and check the missing dates.
          for (int i = 0; i < priceRecords.length; i++) {
            final response =
                await networkProvider.getPriceRecordByDate(priceRecords[i]);
            if (response.success ?? false) {
              final karat24Value = response.get24KaratRecord();
              if (karat24Value != null) {
                priceRecords.remove(priceRecords[i]);
                foundPrices.add(karat24Value);
              }
            }
          }
        } catch (e, a) {
          emit(PriceRecordsLoadFailed("loading prices was not succesful"));
          return;
        }

        for (int i = 0; i < foundPrices.length; i++) {
          print(
              "Found price date: ${foundPrices[i].date} ${foundPrices[i].priceBirr}");
        }

        final now = DateTime.now();
        emit(PriceRecordsLoaded(foundPrices, now));
      },
    );
  }
}
