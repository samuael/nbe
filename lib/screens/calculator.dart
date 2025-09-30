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
    print(lastUpdated);
    print(latestDate);
    print(areSameDates(latestDate, latestDate));

    if (lastUpdated == null || !areSameDates(lastUpdated, latestDate)) {
      final parsed = Uri.parse(url);
      final response = await http.get(
        parsed,
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
              "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
          "Accept":
              "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "Accept-Language": "en-US,en;q=0.9",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> document = jsonDecode(response.body);

        try {
          final List rates = document['data'];
          cached.setString('last_updated', rates[0]['date'] as String);
          for (var rate in rates) {
            cached.setString(rate["gold_type"]["karat"], rate["price_birr"]);
            pricesMap[rate["gold_type"]["karat"]] = rate["price_birr"];
          }
          print(pricesMap);
        } catch (e) {
          print('Something wrong in caching');
        }
      } else {
        print('Failed to load page');
        print(response.statusCode);
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
      print("From Cache $pricesMap");
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
              height: 120,
              width: double.infinity,
              child: Card(
                shadowColor: Colors.grey,
                child: Column(
                  children: [
                    Text(
                      'Today\'s National Bank Rate for\n 24 Karat Gold',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '${pricesMap['24'] ?? '0'} EtB per gram ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        backgroundColor: Colors.grey[400],
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Card(
                shadowColor: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Immediate Payment Amount: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color.fromARGB(181, 158, 158, 158),
                            ),
                            child: Text('95%', style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Tax per gram: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(181, 158, 158, 158),
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(1),
                            child: Text(
                              '5000 EtB',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Bank Fee in Percentage: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(181, 158, 158, 158),
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(1),
                            child: Text(
                              '0.01%',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Bonus by NBE: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(181, 158, 158, 158),
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(1),
                            child: Text('10%', style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
              child: TextField(
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(label: Text('Weight in grams')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
              child: TextField(
                controller: _specificGravityController,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  label: Text('Specific gravity in cm^3'),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final transaction = calculate();
                if (transaction == null) {
                  return;
                }
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
