import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  // final TextEditingController _specificGravityController =
  //     TextEditingController();
  final TextEditingController _karatController = TextEditingController();

  String weightError = "";
  String volumeErr = "";
  String specificGravityErr = "";
  String karatErr = "";

  Setting _setting =
      Setting("${DateTime.now().millisecondsSinceEpoch}", 250, 0.01, 5, 15);

  // areSameDates to check if the day has changed
  bool areSameDates(DateTime day1, DateTime day2) {
    return day1.toIso8601String().substring(0, 10) ==
        day2.toIso8601String().substring(0, 10);
  }

  int index = 1;
  double? karat;
  double? specificGravity;
  double? volume;
  double? weight;

  double? karat24Price;
  double? karat24AfterBonous;
  bool showAllKaratValues = false;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(days: 1),
        content: Text(message),
        action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _getSettings();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
      ),
    );
  }

  Transaction? _calculate() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || specificGravity == null) {
      return null;
    }

    // final rate = ((karat24AfterBonous! * karat!) / 24);
    // final totalAmount = rate * weight;
    return Transaction(
      "${DateTime.now().millisecondsSinceEpoch}",
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      weight,
      karat!,
      _setting.id,
      karat24AfterBonous!,
      athPrice: karat24AfterBonous!,
      specificGravity: specificGravity!,
    );
  }

  void _getSettings() async {
    setState(() {
      _setting =
          Setting("${DateTime.now().millisecondsSinceEpoch}", 250, 0.01, 5, 15);
    });
  }

  void calculateValues() {
    final weight = double.tryParse(_weightController.text);
    volume = double.tryParse(_volumeController.text);
    setState(() {
      if (weight != null && volume != null) {
        specificGravity = weight / volume!;
        karat = ((specificGravity! - 10.51) * 52.838) /
            (specificGravity! - (specificGravity! % 0.01));
        karat = karat! - (karat! % 0.01);
        volumeErr = "";
      }
    });
  }

  @override
  void initState() {
    _getSettings();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final TextStyle _commonLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black.withValues(alpha: .5),
    overflow: TextOverflow.visible,
  );

  @override
  Widget build(BuildContext context) {
    final priceWatch = context.read<PriceRecordBloc>();
    if (priceWatch.state is! PriceRecordsLoaded) {
      priceWatch.add(LoadPriceRecordsEvent());
    }

    final todaysPriceRecord = context.read<TodaysPriceRecordBloc>();
    final todayPriceLoad = context.watch<TodaysPriceRecordBloc>();
    if (todayPriceLoad.state is! TodayPriceRecordsLoaded) {
      todaysPriceRecord.add(LoadTodaysPriceRecordsEvent());
    }

    if (todayPriceLoad.state is TodayPriceRecordsLoaded) {
      final karat24PriceString =
          (todayPriceLoad.state as TodayPriceRecordsLoaded)
              .response
              .data!
              .firstWhere((el) {
        print(el.goldType!.karat);
        return el.goldType!.karat == "24";
      }).priceBirr;

      karat24Price = double.tryParse(karat24PriceString ?? '');

      karat24AfterBonous = karat24Price;
      if (karat24AfterBonous != null) {
        karat24AfterBonous = karat24AfterBonous! + (karat24AfterBonous! * .15);
      }
    }
    final Container _tinyDivider = Container(
      color: Colors.amber.withValues(alpha: .1),
      width: MediaQuery.of(context).size.width * .5,
      height: 0.5,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculate',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * .9,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.orange),
                  right: BorderSide(color: Colors.orange),
                ),
              ),
              // padding: const EdgeInsets.symmetric(horizontal: 10.0),
              margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
              child: TitledContainer(
                'Today\'s National Bank Rate',
                (showAllKaratValues
                        ? ["24", "23", "22", "21", "20", "19", "18", "16"]
                        : [
                            "24",
                          ])
                    .map<Column>((k) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '$k Karrat',
                            textAlign: TextAlign.center,
                            style: k == "24"
                                ? TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black.withValues(alpha: .8),
                                    overflow: TextOverflow.visible,
                                  )
                                : _commonLabelStyle,
                          ),
                          (context.watch<TodaysPriceRecordBloc>().state
                                  is! TodayPriceRecordsLoaded)
                              ? const ShimmerSkeleton(
                                  width: 50,
                                  height: 10,
                                  borderRadius: 2,
                                )
                              : Row(
                                  children: [
                                    Text(
                                      currencyFormatter(double.tryParse((context
                                                          .watch<
                                                              TodaysPriceRecordBloc>()
                                                          .state
                                                      as TodayPriceRecordsLoaded)
                                                  .getPriceRecordByGoldKarat(k)
                                                  ?.priceBirr ??
                                              "") ??
                                          0),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'ብር/ ግራም ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Colors.black.withValues(alpha: .5),
                                      ),
                                    )
                                  ],
                                ),
                        ],
                      ),
                      _tinyDivider,
                    ],
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Checkbox(
                    value: showAllKaratValues,
                    onChanged: (val) {
                      setState(() {
                        showAllKaratValues = val ?? false;
                      });
                    }),
                Text(
                  "Show all karat prices",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: .5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.orange),
                  right: BorderSide(color: Colors.orange),
                ),
              ),
              child: Row(children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    '24 Karat After 15% Bonus ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: karat24AfterBonous == null
                      ? const ShimmerSkeleton(width: 100, height: 10)
                      : Text(
                          NumberFormat('#.####').format(karat24AfterBonous),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black.withValues(alpha: .7),
                          ),
                        ),
                ),
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                fancySelectOneWidget(
                  context,
                  1,
                  "Volume",
                  (val) {
                    setState(() {
                      index = val;
                    });
                  },
                  () {
                    return index;
                  },
                  widthMultiplier: .5,
                ),
                fancySelectOneWidget(context, 2, "Karat", (val) {
                  setState(() {
                    index = val;
                  });
                }, () {
                  return index;
                }, widthMultiplier: .5),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: CommonTextField(
                borderRadius: 5,
                controller: _weightController,
                label: "Weight in grams",
                errorMessage: weightError,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      weight = double.tryParse(val);
                    });
                  }
                  calculateValues();
                },
                keyboardType: const TextInputType.numberWithOptions(),
                enabled: (todayPriceLoad.state is TodayPriceRecordsLoaded),
              ),
            ),
            if (index == 2)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.orange),
                    right: BorderSide(color: Colors.orange),
                  ),
                ),
                child: Row(children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Volume in cm^3 ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: volume == null
                        ? const ShimmerSkeleton(width: 100, height: 10)
                        : Text(
                            '$volume',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Colors.black.withValues(alpha: .7),
                            ),
                          ),
                  ),
                ]),
              ),
            if (index == 1)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: CommonTextField(
                  borderRadius: 5,
                  label: "Volume in cm^3",
                  errorMessage: volumeErr,
                  onChanged: (val) {
                    final value = double.tryParse(val);
                    if (value == null) {
                      setState(() {
                        volumeErr = "invalid volume $val";
                      });
                      return;
                    }
                    calculateValues();
                  },
                  controller: _volumeController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  enabled: (todayPriceLoad.state is TodayPriceRecordsLoaded),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.orange),
                  right: BorderSide(color: Colors.orange),
                ),
              ),
              child: Row(children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Specific Gravity ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                /*String currencyFormatterForPrint(double value) {
  final formatter = NumberFormat('#,##0.##');
  final formattedValue = formatter.format(value);
  return '$formattedValue Birr';
}*/
                Expanded(
                  flex: 1,
                  child: specificGravity == null
                      ? const ShimmerSkeleton(width: 100, height: 10)
                      : Text(
                          NumberFormat('#.##').format(specificGravity),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black.withValues(alpha: .7),
                          ),
                        ),
                ),
              ]),
            ),
            if (index == 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: CommonTextField(
                  borderRadius: 5,
                  label: "Karat",
                  errorMessage: karatErr,
                  onChanged: (val) {
                    final value = double.tryParse(val);
                    if (value == null) {
                      setState(() {
                        karatErr = "invalid karat $val";
                      });
                      return;
                    }
                    if (value < 18 || value > 24) {
                      setState(() {
                        karatErr = "karat must be between 18-24";
                      });
                      return;
                    }
                    setState(() {
                      karat = value;
                      karatErr = "";

                      // weight = double.tryParse(_weightController.text);
                    });
                  },
                  controller: _karatController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  enabled: (todayPriceLoad.state is TodayPriceRecordsLoaded),
                ),
              ),
            if (index == 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: const BorderSide(color: Colors.orange),
                    right: const BorderSide(color: Colors.orange),
                    bottom: BorderSide(
                      color: Colors.black.withValues(alpha: .05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Karat ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: karat == null
                          ? const ShimmerSkeleton(width: 100, height: 10)
                          : Text(
                              NumberFormat('#.##').format(karat),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black.withValues(alpha: .7),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            FancyWideButton(
              "Calculate",
              () {
                if (_weightController.text.isEmpty) {
                  setState(() {
                    weightError = "weight is required";
                  });
                  return;
                } else if (specificGravity == null) {
                  setState(() {
                    specificGravityErr = "specific gravity is required";
                  });
                } else {
                  setState(() {
                    weightError = "";
                    specificGravityErr = "";
                  });
                }
                final transaction = _calculate();
                if (transaction == null) {
                  return;
                }
                // _specificGravityController.clear();
                // _weightController.clear();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => CalculationDetails(
                      transaction: transaction,
                      setting: _setting,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
