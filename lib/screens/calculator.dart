import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';
import 'package:nbe/states/selected_transaction_event.dart';
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

  // Transaction? _calculate() {
  //   final weight = double.tryParse(_weightController.text);
  //   if (weight == null || specificGravity == null) {
  //     return null;
  //   }

  //   // final rate = ((karat24AfterBonous! * karat!) / 24);
  //   // final totalAmount = rate * weight;
  //   return Transaction(
  //     "${DateTime.now().millisecondsSinceEpoch}",
  //     DateFormat('yyyy-MM-dd').format(DateTime.now()),
  //     weight,
  //     karat!,
  //     _setting.id,
  //     karat24AfterBonous!,
  //     athPrice: karat24AfterBonous!,
  //     specificGravity: specificGravity!,
  //   );
  // }

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

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    selectedDate ??= DateTime.now();

    final priceWatch = context.read<PriceRecordBloc>();
    if (priceWatch.state is! PriceRecordsLoaded) {
      priceWatch.add(LoadPriceRecordsEvent());
    }

    final todaysPriceRecord = context.read<TodaysPriceRecordBloc>();
    final todayPriceLoad = context.watch<TodaysPriceRecordBloc>();
    if (todayPriceLoad.state is! TodayPriceRecordsLoaded) {
      todaysPriceRecord.add(LoadTodaysPriceRecordsEvent());
    }

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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
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
                    enableCheck: false,
                    widthMultiplier: 2,
                  ),
                  fancySelectOneWidget(
                    context,
                    2,
                    "Karat",
                    (val) {
                      setState(() {
                        index = val;
                      });
                    },
                    () {
                      return index;
                    },
                    enableCheck: false,
                    widthMultiplier: 2,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().add(const Duration(days: -50)),
                  lastDate: DateTime.now(),
                  barrierColor:
                      Theme.of(context).primaryColorLight.withValues(alpha: .3),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                  context
                      .read<SelectedDatePriceRecordBloc>()
                      .add(SelectOtherDatePriceRecordEvent(selectedDate!));
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // if (selectedDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(children: [
                              Text(
                                'Select Transaction Date: ${DateFormat.yMMMMd().format(selectedDate!)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
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
                                      'Calculating rate ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: BlocBuilder<
                                        SelectedDatePriceRecordBloc,
                                        SelectedDatePriceRecordState>(
                                      builder: (context, state) {
                                        switch (state.runtimeType) {
                                          case SelectedDatePriceRecordInit:
                                            return const ShimmerSkeleton(
                                                width: 100, height: 10);
                                          case SelectedDatePriceRecordLoaded:
                                            return Text(
                                              NumberFormat('#.####').format((state
                                                      as SelectedDatePriceRecordLoaded)
                                                  .record
                                                  .get24KaratRecord()!
                                                  .priceBirr!),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Colors.black
                                                    .withValues(alpha: .7),
                                              ),
                                            );
                                          default:
                                            return Stack(
                                              children: [
                                                const ShimmerSkeleton(
                                                    width: 100, height: 10),
                                                GestureDetector(
                                                  onTap: () {
                                                    context
                                                        .read<
                                                            SelectedDatePriceRecordBloc>()
                                                        .add(
                                                            SelectOtherDatePriceRecordEvent(
                                                                DateTime
                                                                    .now()));
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                          Icons.replay_outlined,
                                                          color: Colors.black
                                                              .withValues(
                                                                  alpha: .5)),
                                                      const Text(
                                                        "Reload",
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            );
                                        }
                                      },
                                    ),
                                  ),
                                ]),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
            const SizedBox(height: 10),
            FancyWideButton(
              "Calculate",
              () => (BuildContext context) async {
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
                // final transaction = _calculate();
                // if (transaction == null) {
                //   return;
                // }
                try {
                  context.read<SelectedTransactionBloc>().add(
                        SelectTransaction(
                          Transaction(
                            "${DateTime.now().millisecondsSinceEpoch / 1000}",
                            DateFormat('yyyy-MM-dd').format(selectedDate!),
                            weight!,
                            karat!,
                            "",
                            0,
                            athPrice: 0,
                            // currentPrice,
                            // athPrice: currentPrice,
                            specificGravity: specificGravity,
                          ),
                        ),
                      );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => CalculationDetails(
                          // transaction: transaction,
                          // setting: _setting,
                          ),
                    ),
                  );
                } catch (e, a) {
                  print(e.toString());
                  print(a.toString());
                }
                //
              }(context),
            ),
          ],
        ),
      ),
    );
  }
}
