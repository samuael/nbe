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
            _createListTile('Gold in Grams', '${widget.transaction.weight} g'),
            _createListTile(
                'Specific Gravity', '${widget.transaction.specificGravity}'),
            _createListTile('Karat', 'K'),
            _createListTile('Purchasing Rate',
                currencyFormatter(widget.transaction.todayRate)),
            const Divider(),
            Text("Settings", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _createListTile('Immediate Payment:', '95%'),
            _createListTile('Tax per Gram:', '5000 EtB'),
            _createListTile('Bank Fee in Percentage:', '0.01%'),
            _createListTile('Bonus', '10%'),
            const SizedBox(
              height: 20,
            ),
            FancyWideButton('Print', () {})
          ],
        ),
      ),
    );
  }
}
