import 'package:nbe/libs.dart';

class CalculationDetails extends StatefulWidget {
  final Transaction transaction;
  final Setting setting;
  const CalculationDetails(
      {required this.transaction, required this.setting, super.key});
  @override
  State<CalculationDetails> createState() => _CalculationDetailsState();
}

class _CalculationDetailsState extends State<CalculationDetails> {
  final _remainingController = TextEditingController();
  late final double tax;
  late final double bonus;
  late final double bankFee;
  final immediatePayment = 0.95;
  bool isSaving = false;

  double taxValue = 0;
  double bonusValue = 0;
  double bankFeeValue = 0;
  double immediatePaymentValue = 0;
  double netValue = 0;
  double netCompleted = 0;

  final TextStyle _commonLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black.withOpacity(.5),
    overflow: TextOverflow.visible,
  );

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
    final db = NBEDatabase.constructor([
      SettingLocalProvider.createOrReplaceTableString(),
    ]);
    setState(() {
      isSaving = true;
    });
    await DataHandler.instance.ensureTableExists('setting');
    await DataHandler.instance.addTransactionToDb(widget.transaction);
    await SettingLocalProvider(db).insertSetting(widget.setting);

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
    tax = widget.setting.taxPerGram;
    bankFee = widget.setting.bankFeePercentage;
    bonus = widget.setting.excludePercentage;
    calculateValues();
    super.initState();
  }

  final TextStyle _labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    overflow: TextOverflow.visible,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculation Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total of ${immediatePayment * 100}%",
                      textAlign: TextAlign.center,
                      style: _commonLabelStyle,
                    ),
                    Row(
                      children: [
                        Text(
                          currencyFormatter(immediatePaymentValue),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "BIRR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(.5),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bank Fee',
                      textAlign: TextAlign.center,
                      style: _commonLabelStyle,
                    ),
                    Row(
                      children: [
                        Text(
                          currencyFormatter(bankFeeValue),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "BIRR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(.5),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tax',
                      textAlign: TextAlign.center,
                      style: _commonLabelStyle,
                    ),
                    Row(
                      children: [
                        Text(
                          currencyFormatter(taxValue),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "BIRR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(.5),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net',
                      textAlign: TextAlign.center,
                      style: _commonLabelStyle,
                    ),
                    Row(
                      children: [
                        Text(
                          currencyFormatter(netValue),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "BIRR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(.5),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: CommonTextField(
                    borderRadius: 5,
                    controller: _remainingController,
                    errorMessage: "",
                    label: "Remaining",
                    onChanged: (val) {},
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Completed',
                      textAlign: TextAlign.center,
                      style: _commonLabelStyle,
                    ),
                    Row(
                      children: [
                        Text(
                          currencyFormatter(netCompleted),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "BIRR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(.5),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                FancyWideButton(
                  "Save",
                  onSaveTapped,
                  animateOnClick: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
