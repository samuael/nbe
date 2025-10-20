import 'package:nbe/libs.dart';

class PriceNetworkRecordProvider {
  final DataProvider networkProvider;

  PriceNetworkRecordProvider(this.networkProvider);

  Future<PriceRecordResponse> getPriceRecordByDate(String date) async {
    return networkProvider.get("/api/filter-gold-rates", {"date": date});
  }
}
