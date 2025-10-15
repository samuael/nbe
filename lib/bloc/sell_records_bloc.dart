import 'package:nbe/libs.dart';

class SellRecordsBloc extends Bloc<SellRecordEvent, SellRecordState> {
  final SellRecordLocalProvider provider;
  SellRecordsBloc(this.provider) : super(SellRecordInit()) {
    on<SellRecordLoad>(
      (event, emit) async {
        int offset = 0;
        int limit = 0;
        if (state is SellRecordLoaded) {
          offset = (state as SellRecordLoaded).records.length;
          limit = offset + 10;
        }
        final result = await provider.getRecentSellRecord(offset, limit);
        if (result != null) {
          if (state is SellRecordLoaded) {
            final records = (state as SellRecordLoaded).records;
            result.forEach(
              (el) {
                records.putIfAbsent(el.id, () {
                  return el;
                });
              },
            );
            emit(SellRecordLoaded(records));
          } else {
            emit(SellRecordLoaded(Map.fromIterable(
              result,
              key: (obj) => obj.id,
              value: (obj) => obj,
            )));
          }
        }
      },
    );

    on<UpdateRecordEvent>((event, emit) {
      if (state is SellRecordLoaded) {
        final dmap = (state as SellRecordLoaded).records;
        dmap[event.record.id] = event.record;
        emit(SellRecordLoaded(dmap));
      }
    });
  }

  Future<bool> saveRecord(SellRecord record) async {
    if (record.id == 0) {
      return false;
    }
    return provider.saveRecord(record);
  }
}
