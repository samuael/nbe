import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';
import 'package:nbe/states/selected_transaction_event.dart';

class SelectedTransactionBloc
    extends Bloc<SelectedTransactionEvent, SelectedTransactionState> {
  final PriceRecordProvider provider;
  final PriceNetworkRecordProvider networkProvider;
  final StringDataProvider stringProvider;

  final dateFormat = DateFormat('yyyy-MM-dd');

  // generate dates
  SelectedTransactionBloc(
      this.provider, this.networkProvider, this.stringProvider)
      : super(SelectedTransactionInit()) {
    on<SelectTransaction>((event, emit) {
      emit(TransactionSelected(event.transaction));
      return;
    });

    on<RemoveTransactionSelection>((event, emit) {
      emit(SelectedTransactionInit());
      return;
    });
  }
}
