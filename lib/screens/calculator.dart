import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nbe/screens/calculation_details.dart';
import 'package:nbe/services/data_handler.dart';
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
  final uuid = Uuid();

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
      latestDate = latestDate.subtract(Duration(days: 1));
    }

    if (lastUpdated == null || !areSameDates(lastUpdated, latestDate)) {
      final parsed = Uri.parse(url);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gold Purchaser'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
          IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Container(
                width: double.infinity,
                // color: Colors.grey,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(123, 0, 0, 0),
                  image: DecorationImage(
                    opacity: 0.5,
                    fit: BoxFit.cover,
                    image: Image.asset(
                      'lib/assets/images/gold_pic.png',
                      width: double.infinity,
                    ).image,
                  ),
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                // shadowColor: Colors.grey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Today\'s National Bank Rate for\n 24 Karat Gold',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '${currencyFormatter(double.tryParse(pricesMap['24'] ?? '') ?? 0)} per gram ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ListTile(
                    title: Text(
                      'Immediate Payment Amount: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    trailing: Text('95%'),
                  ),
                  ListTile(
                    title: Text('Tax per gram'),
                    trailing: Text('5000 EtB'),
                  ),

                  ListTile(
                    title: Text('Bank Fee in percent:'),
                    trailing: Text('0.01%'),
                  ),

                  ListTile(title: Text('Bonus by NBE:'), trailing: Text('10%')),
                ],
              ),
            ),
            Divider(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
              child: TextField(
                cursorColor: Colors.white,
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  label: Text(
                    'Weight in grams',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
              child: TextField(
                cursorColor: Colors.white,
                controller: _specificGravityController,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  label: Text(
                    'Specific gravity in cm^3',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final transaction = calculate();
                if (transaction == null) {
                  return;
                }
                _specificGravityController.clear();
                _weightController.clear();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) =>
                        CalculationDetails(transaction: transaction),
                  ),
                );
              },
              child: Text('Calculate', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
