import 'package:flutter/material.dart';
import 'package:nbe/services/data_handler.dart';

class CalculationDetails extends StatefulWidget {
  final Transaction transaction;
  const CalculationDetails({required this.transaction, super.key});
  @override
  State<CalculationDetails> createState() => _CalculationDetailsState();
}

class _CalculationDetailsState extends State<CalculationDetails> {
  final _remainingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculation Details')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(title: Text('Total of 95%'), trailing: Text('122232 Etb')),
            ListTile(title: Text('Bank Fee:'), trailing: Text('12230 Etb')),
            ListTile(title: Text('Tax:'), trailing: Text('5000 Etb')),
            ListTile(title: Text('Net:'), trailing: Text('1230 Etb')),
            Divider(),

            TextField(
              controller: _remainingController,
              decoration: InputDecoration(label: Text('Remaining')),
            ),
            ListTile(
              title: Text('Net Complete:'),
              subtitle: Text('12314212 Etb'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 60)),
              ),
              onPressed: () {},
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
