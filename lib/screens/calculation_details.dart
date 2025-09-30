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
  final tax = 100;
  final bonus = 0.1;
  final bankFee = 0.0001;
  final immediatePayment = 0.95;

  double taxValue = 0;
  double bonusValue = 0;
  double bankFeeValue = 0;
  double immediatePaymentValue = 0;
  double netValue = 0;
  double netCompleted = 0;

  void calculateValues() {
    final tran = widget.transaction;
    setState(() {
      immediatePaymentValue = immediatePayment * tran.totalAmount;
      taxValue = tax * tran.weight;
      bonusValue = bonus * tran.totalAmount;
      bankFeeValue = bankFee * tran.totalAmount;
      netValue =
          (immediatePaymentValue + bonusValue) - (taxValue + bankFeeValue);
      netCompleted =
          (tran.totalAmount + bonusValue) - (taxValue + bankFeeValue);
    });
  }

  @override
  void initState() {
    calculateValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculation Details')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Total of 95%'),
              trailing: Text(currencyFormatter(immediatePaymentValue)),
            ),
            ListTile(
              title: Text('Bank Fee:'),
              trailing: Text(currencyFormatter(bankFeeValue)),
            ),
            ListTile(
              title: Text('Tax:'),
              trailing: Text(currencyFormatter(taxValue)),
            ),
            ListTile(
              title: Text('Net:'),
              trailing: Text(currencyFormatter(netValue)),
            ),
            Divider(),

            TextField(
              controller: _remainingController,
              decoration: InputDecoration(label: Text('Remaining')),
            ),
            ListTile(
              title: Text('Net Complete:'),
              subtitle: Text(currencyFormatter(netCompleted)),
            ),
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 60)),
              ),
              onPressed: () {
                DataHandler().addTransactionToDb(widget.transaction);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
