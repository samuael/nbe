import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _specificGravityController =
      TextEditingController();
  double purchaseRate = 0;
  String demoText = '';
  final url = 'https://nbe.gov.et/exchange/gold-purchasing-rate/';

  bool areSameDates(DateTime day1, DateTime day2) {
    return day1.toIso8601String().substring(0, 10) ==
        day2.toIso8601String().substring(0, 10);
  }

  Future<void> getPurchasingRate() async {
    // final cached = await SharedPreferences.getInstance();

    // DateTime? lastUpdated = DateTime.tryParse(
    //   cached.getString('lastUpdated') ?? '',
    // );

    DateTime? lastUpdated = null;

    if (lastUpdated == null || !areSameDates(lastUpdated, DateTime.now())) {
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
        dom.Document document = parser.parse(response.body);
        final table = document.querySelector('table');
        if (table == null) {
          print('No table');
          return;
        }
        final rows = table.querySelectorAll('tr');
        if (rows.isEmpty) {
          print('no rows');
          return;
        } else {
          print(rows.length);
          return;
        }
        final firstDataRow = rows.firstWhere(
          (row) => row.querySelectorAll('td').isNotEmpty,
        ); //24 Karat's
        if (firstDataRow.querySelectorAll('td').isEmpty) {
          print('no table data');
          return;
        }
        final loadedPurchaseRate = firstDataRow.querySelectorAll('td')[0];
        print(loadedPurchaseRate.text);
        setState(() {
          demoText = loadedPurchaseRate.text;
        });
      } else {
        print('Failed to load page');
        print(response.statusCode);
      }
    }
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
                      '$purchaseRate EtB per gram $demoText',
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
              onPressed: () {},
              child: Text('Calculate', style: TextStyle(fontSize: 20)),
            ),
            ElevatedButton(
              onPressed: getPurchasingRate,
              child: Text('Get Today\'s Rate'),
            ),
          ],
        ),
      ),
    );
  }
}
