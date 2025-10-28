import 'package:nbe/libs.dart';

import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  Set<String> selectedTransactions = {};
  Set<String> selectedMonths = {};
  bool selecting = false;

  void _showPrintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              "Select Month & Year",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem(
                      value: month,
                      child: Text(DateFormat.MMMM().format(DateTime(0, month))),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedMonth = value;
                      });
                    }
                  },
                ),
                DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(10, (index) {
                    final year = DateTime.now().year - 5 + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedYear = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(ctx),
              ),
              ElevatedButton(
                child: const Text("Print"),
                onPressed: () {
                  final transactions = _getTransactionsForMonthYear(
                    ctx,
                    selectedMonth,
                    selectedYear,
                  );
                  Navigator.pop(ctx);
                },
              ),
            ],
          );
        });
      },
    );
  }

  List<Transaction> _getTransactionsForMonthYear(
      BuildContext context, int month, int year) {
    return (context.watch<TransactionsBloc>().state as TransactionLoaded)
        .records
        .values
        .where((t) {
      final dtime = DateTime.fromMillisecondsSinceEpoch(t.createdAt * 1000);
      return dtime.month == month && dtime.year == year;
    }).toList();
  }

  @override
  void initState() {
    // _loadRecords();
    super.initState();
  }

  Map<String, Transaction>? records;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Transaction>> grouped = {};

    if (context.watch<TransactionsBloc>().state is TransactionLoaded) {
      records = (context.watch<TransactionsBloc>().state as TransactionLoaded)
          .records;

      for (var tran in records!.values) {
        final key = DateFormat.yMMMM().format(tran.date);
        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(tran);
      }
    }

    final months = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [Icon(Icons.history), SizedBox(width: 10), Text('History')],
        ),
        actions: [
          IconButton(
            onPressed: () {
              final Set dSelectedMonths = {};
              final selectedTransactionIDs = records!.values.map<String>((tr) {
                return tr.id;
              }).toList();
              setState(() {
                if (selectedTransactions.isEmpty) {
                  selectedTransactions.addAll(selectedTransactionIDs);
                  selecting = true;
                } else {
                  selectedTransactions.removeAll(selectedTransactionIDs);
                  selecting = false;
                }
              });
            },
            icon: Row(
              children: [
                Text(
                  "Select all",
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: .5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.check_box,
                  color: records!.values.length == selectedTransactions.length
                      ? Theme.of(context).primaryColorLight
                      : Colors.black.withValues(alpha: .1),
                  size: 18,
                )
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                context
                    .read<TransactionsBloc>()
                    .add(DeleteTransactionsEvent(selectedTransactions));
              },
              icon: const Icon(
                Icons.delete,
                size: 18,
              )),
          Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                  onPressed: () {
                    _showPrintDialog(context);
                  },
                  icon: const Icon(Icons.print)))
        ],
      ),
      body: months.isNotEmpty
          ? ListView.builder(
              itemCount: months.length,
              itemBuilder: (ctx, index) {
                final month = months[index];
                final transactions = grouped[month]!;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => (String mon) {
                          if (selectedMonths.contains(mon)) {
                            selectedTransactions
                                .removeAll(transactions.map<String>((el) {
                              return el.id;
                            }).toList());
                          } else {
                            selectedTransactions
                                .addAll(transactions.map<String>((el) {
                              return el.id;
                            }).toList());
                          }
                        }(month),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              month,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              selectedMonths.contains(month)
                                  ? Icons.rectangle_outlined
                                  : Icons.rectangle_outlined,
                              color: selectedMonths.contains(month)
                                  ? Theme.of(context).primaryColor
                                  : Colors.black.withValues(alpha: .1),
                            ),
                          ],
                        ),
                      ),
                      ...transactions.map(
                        (transaction) {
                          return Stack(
                            children: [
                              if (selecting)
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.check_box,
                                    color: selectedTransactions
                                            .contains(transaction.id)
                                        ? Theme.of(context).primaryColorLight
                                        : Colors.black.withValues(alpha: .1),
                                    size: 18,
                                  ),
                                ),
                              TransactionItemView(
                                transaction,
                                selecting: selecting,
                                onSelect: (String transactionID) {
                                  setState(() {
                                    if (selectedTransactions
                                        .contains(transactionID)) {
                                      selectedTransactions.add(transactionID);
                                    } else {
                                      selectedTransactions
                                          .remove(transactionID);
                                    }
                                    if (selectedTransactions.isNotEmpty) {
                                      selecting = true;
                                    }
                                    // if(selectedMonths.contains(month)  )
                                  });
                                },
                                isSelected: (String id) {
                                  return selectedTransactions.contains(id);
                                },
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                );
              },
            )
          : noOrderFound(),
    );
  }

  Widget noOrderFound() {
    return Column(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.post_add_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Deposit transaction recorded',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Calculate and record your transasction to the national bank for later use and proper record management',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
