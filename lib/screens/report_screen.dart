import 'package:flutter/material.dart';
import 'package:nbe/libs.dart';
import 'package:nbe/services/data_handler.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<Transaction> transactions = [];

  void _loadTransactions() async {
    final tran = await DataHandler.instance.loadAllTransactions();
    print(tran.length);

    setState(() {
      transactions.addAll(tran.reversed);
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
      appBar: AppBar(
        title: const Row(
          children: [Icon(Icons.history), SizedBox(width: 10), Text('History')],
        ),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (ctx, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Color.fromARGB(160, 158, 158, 158)))),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ReportDetailsScreen(
                            transaction: transactions[index],
                          )));
                },
                leading:
                    Text(DateFormat.MMMd().format(transactions[index].date)),
                title: Text(
                  '${transactions[index].weight.toStringAsFixed(2)} gram',
                ),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.check), Text('Completed')],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
