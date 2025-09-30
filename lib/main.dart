import 'package:flutter/material.dart';
import 'package:nbe/screens/calculator.dart';
import 'package:nbe/screens/report_screen.dart';

final ThemeData theme = ThemeData(
  scaffoldBackgroundColor: const Color.fromARGB(255, 3, 37, 65),
  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.grey,
      fontStyle: FontStyle.italic,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(
        const Color.fromARGB(255, 3, 48, 85),
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromARGB(255, 3, 37, 65),
    foregroundColor: Colors.amber,
    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  ),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      title: 'Gold Purchasing Rate',
      home: NavigationController(),
    );
  }
}

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;
  static const List<Widget> widgetList = [
    CalculatorScreen(),
    ReportScreen(),
    Center(child: Text('Index 2')),
    Center(child: Text('Index 3')),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetList[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        fixedColor: Colors.amber,
        backgroundColor: const Color.fromARGB(255, 1, 28, 49),

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grading_sharp),
            label: 'Report',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
    );
  }
}
