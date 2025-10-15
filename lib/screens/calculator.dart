import 'dart:convert';
// import 'package:nbe/database/database.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nbe/libs.dart';
// import 'package:nbe/screens/calculation_details.dart';
// import 'package:nbe/services/data_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final TextEditingController _specificGravityController =
      TextEditingController();
  final TextEditingController _karatController = TextEditingController();

  String weightError = "";
  String volumeErr = "";
  String specificGravityErr = "";
  String karatErr = "";

  Map<String, String> pricesMap = {};
  final url = 'https://api.nbe.gov.et/api/filter-gold-rates';
  Setting _setting = Setting(uuid.v4(), 0, 250, 0.01, 0.1);

  //to check if the day has changed
  bool areSameDates(DateTime day1, DateTime day2) {
    return day1.toIso8601String().substring(0, 10) ==
        day2.toIso8601String().substring(0, 10);
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

  int index = 1;
  double? karat;
  double? specificGravity;
  double? volume;
  double? weight;

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
              _getPurchasingRate();
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

    // int estimatedCarat = 0;
    // if (specificGravity! <= 19.51 && specificGravity! > 19.13) {
    //   estimatedCarat = 24;
    // } else if (specificGravity! <= 19.13 && specificGravity! > 18.24) {
    //   estimatedCarat = 23;
    // } else if (specificGravity! <= 18.24 && specificGravity! > 17.45) {
    //   estimatedCarat = 22;
    // } else if (specificGravity! <= 17.45 && specificGravity! > 17.11) {
    //   estimatedCarat = 21;
    // } else if (specificGravity! <= 17.11 && specificGravity! > 16.03) {
    //   estimatedCarat = 20;
    // } else if (specificGravity! <= 16.03 && specificGravity! > 15.2) {
    //   estimatedCarat = 18;
    // }

    // final rate = pricesMap[estimatedCarat.toString()];
    // final rate = pricesMap[estimatedCarat.toString()];
    final rate = ((karat24AfterBonous! * karat!) / 24);
    final totalAmount = rate * weight;
    return Transaction(
      id: uuid.v4(),
      date: DateTime.now(),
      specificGravity: specificGravity!,
      todayRate: rate,
      totalAmount: totalAmount,
      weight: weight,
      isCompleted: true,
      settingId: _setting.id,
      karat: "${karat!}", // estimatedCarat.toString(),
    );
  }

  void _getSettings() async {
    final db = NBEDatabase.constructor([
      SettingLocalProvider.createOrReplaceTableString(),
    ]);
    // final recentSettings =
    //     await SettingLocalProvider(db).getRecentSettings(0, 10);
    // if (recentSettings.isNotEmpty) {
    //   setState(() {
    //     _setting = recentSettings.last;
    //   });
    // } else {
    setState(() {
      _setting = Setting(uuid.v4(), double.tryParse(pricesMap['24'] ?? '') ?? 0,
          250, 0.01, 0.1);
    });
    // }
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
    _getPurchasingRate();
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
    color: Colors.black.withOpacity(.5),
    overflow: TextOverflow.visible,
  );

  @override
  Widget build(BuildContext context) {
    // if (weight != null) {
    //   _weightController.text = "$weight";
    // }
    karat24AfterBonous = double.tryParse(pricesMap["24"] ?? '');
    if (karat24AfterBonous != null) {
      karat24AfterBonous = karat24AfterBonous! + (karat24AfterBonous! * .15);
    }
    final Container _tinyDivider = Container(
      color: Colors.amber.withOpacity(.1),
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
                                    color: Colors.black.withOpacity(.8),
                                    overflow: TextOverflow.visible,
                                  )
                                : _commonLabelStyle,
                          ),
                          double.tryParse(pricesMap[k] ?? '') == null
                              ? const ShimmerSkeleton(
                                  width: 50,
                                  height: 10,
                                  borderRadius: 2,
                                )
                              : Row(
                                  children: [
                                    Text(
                                      currencyFormatter(
                                          double.tryParse(pricesMap[k] ?? '') ??
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
                                          color: Colors.black.withOpacity(.5)),
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
                          NumberFormat('#.##').format(karat24AfterBonous),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black.withOpacity(.7)),
                        ),
                ),
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                fancySelectOneWidget(context, 1, "Volume", (val) {
                  setState(() {
                    index = val;
                  });
                }, () {
                  return index;
                }, widthMultiplier: .5),
                // fancySelectOneWidget(context, 2, "Specific Gravity", (val) {
                //   setState(() {
                //     index = val;
                //   });
                // }, () {
                //   return index;
                // }, widthMultiplier: .5),
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
                              color: Colors.black.withOpacity(.7)),
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
                    bottom: BorderSide(color: Colors.black.withOpacity(.05)),
                  ),
                ),
                child: Row(children: [
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
                                color: Colors.black.withOpacity(.7)),
                          ),
                  ),
                ]),
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
