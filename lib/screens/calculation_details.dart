import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nbe/libs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculationDetails extends StatefulWidget {
  final Transaction transaction;
  Setting setting;
  CalculationDetails(
      {required this.transaction, required this.setting, super.key});
  @override
  State<CalculationDetails> createState() => _CalculationDetailsState();
}

class _CalculationDetailsState extends State<CalculationDetails> {
  final _remainingController = TextEditingController();
  late final double tax;
  late final double bonus;
  late final double bankFee;
  final immediatePayment = 1;
  bool isSaving = false;
  // Setting _setting = Setting(uuid.v4(), 0, 250, 0.0001, 0.15);

  double taxValue = 0;
  double bonusValue = .15;
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

  Map<String, String> pricesMap = {};
  final url = 'https://api.nbe.gov.et/api/filter-gold-rates';
  // Setting setting = Setting(uuid.v4(), 0, 5000, 0.0001, 0.1);

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
              _getPurchasingRate();
              // _getSettings();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
      ),
    );
  }

  // to get the rates either from cache or from api
  Future<void> _getPurchasingRate() async {
    final cached = await SharedPreferences.getInstance();
    if (cached.getString('last_updated') != null) {}
    DateTime? lastUpdated = DateTime.tryParse(
      cached.getString('last_updated') ?? '',
    );
    DateTime latestDate = DateTime.now();
    if (latestDate.hour >= 0 && latestDate.hour < 8) {
      latestDate = latestDate.subtract(const Duration(days: 1));
    }

    if (lastUpdated == null || !areSameDates(lastUpdated, latestDate)) {
      final parsed = Uri.parse(url);
      try {
        final response = await http.get(parsed);

        if (response.statusCode == 200) {
          final Map<String, dynamic> document = jsonDecode(response.body);

          try {
            final List rates = document['data'];
            cached.setString(
                'last_updated', DateTime.now().toString().substring(0, 10));
            for (var rate in rates) {
              cached.setString(rate["gold_type"]["karat"], rate["price_birr"]);
              pricesMap[rate["gold_type"]["karat"]] = rate["price_birr"];
            }
            setState(() {});
          } catch (e) {
            print('Something wrong in caching');
          }
        } else {
          if (context.mounted) {
            showSnackBar(
                'Failed to load the purchasing rates. Server error: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (context.mounted) {
          showSnackBar('Failed to load the purchasing rates');
        }
      }
    } else {
      final keys = cached.getKeys();
      for (var key in keys) {
        final value = cached.get(key);
        if (value != null) {
          pricesMap[key] = value as String;
        }
      }
      setState(() {});
    }
  }

  void calculateValues() {
    final tran = widget.transaction;
    // print("Setting: ${widget.transaction.toString()}");
    print(
        "widget.transaction.karat: ${widget.transaction.karat},widget.transaction.specificGravity: ${widget.transaction.specificGravity}, widget.transaction.weight: ${widget.transaction.weight}");
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
                          bottom:
                              BorderSide(color: Colors.black.withOpacity(.05)),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      width: MediaQuery.of(context).size.width * .9,
                      height: MediaQuery.of(context).size.height * .15,
                      child: Stack(
                        children: [
                          TitledContainer(
                            "Settings",
                            [
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Immediate Payment Amount ',
                                    style: _commonLabelStyle,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '95%',
                                    style: _commonLabelStyle,
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text('Tax per gram',
                                      style: _commonLabelStyle),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                      '${widget.setting.taxPerGram} EtB',
                                      style: _commonLabelStyle),
                                ),
                              ]),
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text('Bank Fee in percent:',
                                      style: _commonLabelStyle),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                      '${widget.setting.bankFeePercentage * 100}%',
                                      style: _commonLabelStyle),
                                ),
                              ]),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text('Bonus by NBE:',
                                          style: _commonLabelStyle)),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${widget.setting.excludePercentage * 100}%',
                                      style: _commonLabelStyle,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: () async {
                                final Setting? newSetting = await Navigator.of(
                                        context)
                                    .push(MaterialPageRoute(
                                        builder: (ctx) => SettingsScreen(
                                            nbe24KaratRate: double.tryParse(
                                                    pricesMap['24'] ?? '') ??
                                                0)));

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
                                          .withOpacity(.5)),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
