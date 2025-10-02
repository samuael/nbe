import 'package:nbe/libs.dart';

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
  bool isSaving = false;

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

  void onSaveTapped() async {
    setState(() {
      isSaving = true;
    });
    await DataHandler.instance.addTransactionToDb(widget.transaction);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Saved Successfully'),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    calculateValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculation Details')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: const Text('Total of 95%'),
                trailing: Text(currencyFormatter(immediatePaymentValue)),
              ),
              ListTile(
                title: const Text('Bank Fee:'),
                trailing: Text(currencyFormatter(bankFeeValue)),
              ),
              ListTile(
                title: const Text('Tax:'),
                trailing: Text(currencyFormatter(taxValue)),
              ),
              ListTile(
                title: const Text('Net:'),
                trailing: Text(currencyFormatter(netValue)),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CommonTextField(
                  controller: _remainingController,
                  errorMessage: "",
                  label: "Remaining",
                  onChanged: (val) {},
                ),
              ),
              ListTile(
                title: const Text('Net Complete:'),
                trailing: Text(currencyFormatter(netCompleted)),
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(
                    Size(double.infinity, 60),
                  ),
                ),
                onPressed: onSaveTapped,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
