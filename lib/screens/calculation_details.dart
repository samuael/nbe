import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nbe/libs.dart';

class CalculationDetails extends StatefulWidget {
  final Transaction transaction;
  Setting? setting;
  CalculationDetails({required this.transaction, this.setting, super.key});
  @override
  State<CalculationDetails> createState() => _CalculationDetailsState();
}

class _CalculationDetailsState extends State<CalculationDetails> {
  final _remainingController = TextEditingController();

  double? taxPerGram;
  double? bonusPercentage;
  double? bankFeePercentage;
  double? karat24Price;
  double? immediatePercentage;

  double taxValue = 0;
  double bonusValue = 0;
  double bankFeeValue = 0;
  double immediatePaymentValue = 0;

  double netValue = 0;
  double netCompleted = 0;

  final TextStyle _commonLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black.withValues(alpha: .5),
    overflow: TextOverflow.visible,
  );

  //to check if the day has changed
  bool areSameDates(DateTime day1, DateTime day2) {
    return day1.toIso8601String().substring(0, 10) ==
        day2.toIso8601String().substring(0, 10);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(days: 1),
        content: Text(message),
        action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              // _getPurchasingRate();
              // _getSettings();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
      ),
    );
  }

  void calculateValues() {
    final tran = widget.transaction;
    setState(() {
      // immediatePaymentValue = immediatePercentage * tran.totalAmount;
      // taxValue = taxPerGram * tran.weight;
      // bonusValue = bonusPercentage * tran.totalAmount;
      // bankFeeValue = bankFeePercentage * tran.totalAmount;
      // netValue =
      //     (immediatePaymentValue + bonusValue) - (taxValue + bankFeeValue);
      // netCompleted =
      //     (tran.totalAmount + bonusValue) - (taxValue + bankFeeValue);
    });
  }

  void onSaveTapped(BuildContext context) async {
    if (widget.setting != null) {
      return;
    }
    context.read<SettingBloc>().add(UpdateSettingEvent(widget.setting!));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Saved Successfully'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void initState() {
    // calculateValues();
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
    final settingLoad = context.watch<SettingBloc>();
    if (widget.setting == null && (settingLoad.state is SettingLoaded)) {
      widget.setting = (settingLoad.state as SettingLoaded).setting;
    }

    // todaysPrice
    // final settingCall = context.watch<SettingBloc>();

    if (widget.setting != null) {
      taxPerGram = widget.setting!.taxPerGram;
      bankFeePercentage = widget.setting!.bankFeePercentage;
      bonusPercentage = widget.setting!.bonusByNBEInPercentage;
      immediatePercentage = 1 - widget.setting!.holdPercentage;
    }

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
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .9,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: const BorderSide(color: Colors.orange),
                          right: const BorderSide(color: Colors.orange),
                          bottom: BorderSide(
                            color: Colors.black.withValues(alpha: .05),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      width: MediaQuery.of(context).size.width * .9,
                      height: MediaQuery.of(context).size.height * .15,
                      child: Stack(
                        children: [
                          if (settingLoad.state is SettingLoaded)
                            TitledContainer("Settings", [
                              SettingItem(
                                  (settingLoad.state as SettingLoaded).setting),
                            ]),
                          if (settingLoad.state is! SettingLoaded)
                            SizedBox(
                              child: Column(
                                children: [
                                  const NotificationMessage(
                                      "Setting being loaded"),
                                  SpinKitWanderingCubes(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: () async {
                                final Setting? newSetting = await Navigator.of(
                                        context)
                                    .push(MaterialPageRoute(
                                        builder: (ctx) => const SettingsScreen(
                                            // nbe24KaratRate: double.tryParse(
                                            //         pricesMap['24'] ?? '') ??
                                            nbe24KaratRate: 0)));

                                if (newSetting != null) {
                                  setState(() {
                                    widget.setting = newSetting;
                                  });
                                }
                              },
                              splashColor: Theme.of(context).primaryColor,
                              icon: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: .5)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                      size: 14,
                                    )
                                  ],
                                ),
                              ),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    flex: 8,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total of $immediatePercentage %",
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  currencyFormatWith2DecimalValues(
                                      immediatePaymentValue),
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
                                    color: Colors.black.withValues(alpha: .5),
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
                                  currencyFormatWith2DecimalValues(
                                      bankFeeValue),
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
                                    color: Colors.black.withValues(alpha: .5),
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
                                  currencyFormatWith2DecimalValues(taxValue),
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
                                    color: Colors.black.withValues(alpha: .5),
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
                                  currencyFormatWith2DecimalValues(netValue),
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
                                    color: Colors.black.withValues(alpha: .5),
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
                                  currencyFormatWith2DecimalValues(
                                      netCompleted),
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
                                    color: Colors.black.withValues(alpha: .5),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
