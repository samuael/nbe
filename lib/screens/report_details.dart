import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';
import 'package:nbe/screens/screens.dart';

class ReportDetailsScreen extends StatefulWidget {
  final Transaction transaction;
  const ReportDetailsScreen({super.key, required this.transaction});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  Widget _createListTile(String title, String trailing) {
    return ListTile(
      minVerticalPadding: 0,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: Text(
        trailing,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Date: ${DateFormat.yMMMd().format(widget.transaction.date)}"),
                Chip(
                  label: Text(
                      widget.transaction.isCompleted ? 'Completed' : 'Pending'),
                  backgroundColor: widget.transaction.isCompleted
                      ? Colors.green
                      : Colors.orange,
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            // _createListTile('Gold in Grams', '${widget.transaction.weight} g'),
            // _createListTile(
            //     'Specific Gravity', '${widget.transaction.specificGravity}'),
            // _createListTile('Karat', 'K'),
            // _createListTile('Purchasing Rate',
            //     currencyFormatter(widget.transaction.todayRate)),

            Row(children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'Gold in Grams: ',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${widget.transaction.weight} g',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ]),
            Row(children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'Specific Gravity:',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${widget.transaction.specificGravity}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ]),
            const Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Karat:',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'K',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ]),
            Row(
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      'Purchasing Rate',
                      style: TextStyle(fontSize: 16),
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      currencyFormatter(widget.transaction.todayRate),
                      style: const TextStyle(fontSize: 16),
                    ))
              ],
            ),
            const Divider(),
            const TitledContainer(
              "Settings",
              [
                SizedBox(
                  height: 5,
                ),
                Row(children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Immediate Payment Amount: ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '95%',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Tax per gram',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '5000 EtB',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Bank Fee in percent:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '0.01%',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ]),
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(
                          'Bonus by NBE:',
                          style: TextStyle(fontSize: 16),
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          '10%',
                          style: TextStyle(fontSize: 16),
                        ))
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
