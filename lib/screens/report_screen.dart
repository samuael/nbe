import 'package:nbe/libs.dart';

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
    final Map<String, List<Transaction>> grouped = {};
    for (var tran in transactions) {
      final key = DateFormat.yMMMM().format(tran.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(tran);
    }

    final months = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [Icon(Icons.history), SizedBox(width: 10), Text('History')],
        ),
        actions: [
          Padding(
              padding: const EdgeInsetsGeometry.only(right: 4),
              child:
                  IconButton(onPressed: () {}, icon: const Icon(Icons.print)))
        ],
      ),
      body: ListView.builder(
        itemCount: months.length,
        itemBuilder: (ctx, index) {
          final month = months[index];
          final transactions = grouped[month]!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ...transactions.map((transaction) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromARGB(160, 158, 158, 158)))),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ReportDetailsScreen(
                                    transaction: transaction,
                                  )));
                        },
                        leading: Text(
                          DateFormat.MMMd().format(
                            transaction.date,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        title: Text(
                          '${transaction.weight.toStringAsFixed(2)} gram',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            transaction.isCompleted
                                ? Icon(Icons.check)
                                : Icon(Icons.circle),
                            Text(
                              transaction.isCompleted ? 'Completed' : 'Pending',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          );
        },
      ),
    );
  }
}
