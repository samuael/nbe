import 'package:flutter/material.dart';
import 'package:nbe/services/data_handler.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<Transaction> transactions = [];

  void _loadTransactions() async {
    final tran = await DataHandler().loadAllTransactions();

    setState(() {
      transactions.addAll(tran);
    });
  }

  @override
  void initState() {
    _loadTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (ctx, index) {
          return ListTile(
            leading: Text(transactions[index].date.day.toString()),
            title: Text(transactions[index].weight.toStringAsFixed(2)),
            trailing: Row(children: [Icon(Icons.check), Text('Completed')]),
          );
        },
      ),
    );
  }
}
