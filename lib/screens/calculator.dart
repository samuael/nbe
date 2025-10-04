import 'dart:convert';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nbe/libs.dart';
// import 'package:nbe/screens/calculation_details.dart';
// import 'package:nbe/services/data_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _specificGravityController =
      TextEditingController();
  Map<String, String> pricesMap = {};
  final url = 'https://api.nbe.gov.et/api/filter-gold-rates';
  final uuid = const Uuid();

  //to check if the day has changed
  bool areSameDates(DateTime day1, DateTime day2) {
    return day1.toIso8601String().substring(0, 10) ==
        day2.toIso8601String().substring(0, 10);
  }

  // to get the rates either from cache or from api
  Future<void> getPurchasingRate() async {
    final cached = await SharedPreferences.getInstance();
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
            cached.setString('last_updated', rates[0]['date'] as String);
            for (var rate in rates) {
              cached.setString(rate["gold_type"]["karat"], rate["price_birr"]);
              pricesMap[rate["gold_type"]["karat"]] = rate["price_birr"];
            }
            setState(() {});
          } catch (e) {
            print('Something wrong in caching');
          }
        } else {
          print('Failed to load page. Status Code:${response.statusCode}');
          if (context.mounted) {
            _showSnackBar(
                'Failed to load the purchasing rates. Server error: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar('Failed to load the purchasing rates');
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(days: 1),
        content: Text(message),
        action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              getPurchasingRate();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
      ),
    );
  }

  Transaction? calculate() {
    final weight = double.tryParse(_weightController.text);
    final specificGravity = double.tryParse(_specificGravityController.text);
    if (weight == null || specificGravity == null) {
      return null;
    }

    int estimatedCarat = 0;
    if (specificGravity <= 19.51 && specificGravity > 19.13) {
      estimatedCarat = 24;
    } else if (specificGravity <= 19.13 && specificGravity > 18.24) {
      estimatedCarat = 23;
    } else if (specificGravity <= 18.24 && specificGravity > 17.45) {
      estimatedCarat = 22;
    } else if (specificGravity <= 17.45 && specificGravity > 17.11) {
      estimatedCarat = 21;
    } else if (specificGravity <= 17.11 && specificGravity > 16.03) {
      estimatedCarat = 20;
    } else if (specificGravity <= 16.03 && specificGravity > 15.2) {
      estimatedCarat = 18;
    }

    final rate = pricesMap[estimatedCarat.toString()];
    final totalAmount = (double.tryParse(rate ?? '') ?? 0) * weight;
    return Transaction(
      id: uuid.v4(),
      date: DateTime.now(),
      specificGravity: specificGravity,
      todayRate: double.tryParse(rate ?? '') ?? 0,
      totalAmount: totalAmount,
      weight: weight,
      isCompleted: true,
    );
  }

  @override
  void initState() {
    getPurchasingRate();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gold Purchaser'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Today\'s National Bank Rate for\n 24 Karat Gold',
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${currencyFormatter(double.tryParse(pricesMap['24'] ?? '') ?? 0)} per gram ',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: TitledContainer(
                "Settings",
                [
                  Row(children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Immediate Payment Amount: ',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('95%'),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                      flex: 2,
                      child: Text('Tax per gram'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('5000 EtB'),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                      flex: 2,
                      child: Text('Bank Fee in percent:'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('0.01%'),
                    ),
                  ]),
                  Row(
                    children: [
                      Expanded(flex: 2, child: Text('Bonus by NBE:')),
                      Expanded(flex: 1, child: Text('10%'))
                    ],
                  )
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: CommonTextField(
                controller: _weightController,
                label: "Weight in grams",
                errorMessage: "",
                onChanged: (val) {},
                keyboardType: const TextInputType.numberWithOptions(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: CommonTextField(
                label: "Specific gravity in cm^3",
                errorMessage: "",
                onChanged: (val) {},
                controller: _specificGravityController,
                keyboardType: const TextInputType.numberWithOptions(),
              ),
            ),
            const SizedBox(height: 10),
            FancyWideButton(
              "Calculate",
              () {
                final transaction = calculate();
                if (transaction == null) {
                  return;
                }
                _specificGravityController.clear();
                _weightController.clear();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) =>
                        CalculationDetails(transaction: transaction),
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
