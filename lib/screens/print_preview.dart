import 'package:nbe/libs.dart';

class PrintPreviewScreen extends StatelessWidget {
  final List<Transaction> transactions;
  PrintPreviewScreen({required this.transactions, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print Preview'),
      ),
    );
  }
}
