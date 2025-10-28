import 'libs.dart';

final ThemeData theme = ThemeData(
  // scaffoldBackgroundColor: const Color.fromARGB(255, 3, 37, 65),
  listTileTheme: const ListTileThemeData(
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
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(),
  ),
  appBarTheme: const AppBarTheme(
    // backgroundColor: Color.fromARGB(255, 3, 37, 65),
    foregroundColor: Colors.amber,
    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  ),
);

void main() {
  // Giving the constructor a list of tables to create.
  final Setting setting =
      Setting("${DateTime.now().millisecondsSinceEpoch}", 250, 0.001, 5, 15);
  NBEDatabase nbeDB = NBEDatabase.constructor([
    SettingLocalProvider.createOrReplaceTableString(),
    SettingLocalProvider.insertDefaultSetting(setting),
    StringDataProvider.createOrReplaceTableString(),
    StringDataProvider.insertNBEConstants(
        StaticConstant.MAX_HOLD_DURATION_ID, "90"),
    StringDataProvider.insertNBEConstants(
        StaticConstant.LAST_SETTING_ID, setting.id),
    TransactionsLocalProvider.createOrReplaceTableString(),
    PriceRecordProvider.createOrReplaceTableString(),
  ]);

  final sellRecordProvider = TransactionsLocalProvider(nbeDB);
  final settingProvider = SettingLocalProvider(nbeDB);
  final stringProvider = StringDataProvider(nbeDB);
  final priceDataProvider = PriceRecordProvider(nbeDB);

  final dataNetworkProvider = DataProvider(fullURL: 'https://api.nbe.gov.et');

  final priceDataNetworkProvider =
      PriceNetworkRecordProvider(dataNetworkProvider);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<SettingsBloc>(create: (context) {
        return SettingsBloc(settingProvider);
      }),
      BlocProvider<TransactionsBloc>(create: (context) {
        return TransactionsBloc(sellRecordProvider);
      }),
      BlocProvider<SettingBloc>(create: (context) {
        return SettingBloc(settingProvider, stringProvider);
      }),
      BlocProvider<PriceRecordBloc>(create: (context) {
        return PriceRecordBloc(
            priceDataProvider, priceDataNetworkProvider, stringProvider);
      }),
      BlocProvider<TodaysPriceRecordBloc>(create: (context) {
        return TodaysPriceRecordBloc(
            priceDataProvider, priceDataNetworkProvider, stringProvider);
      }),
      BlocProvider<SelectedDatePriceRecordBloc>(create: (context) {
        return SelectedDatePriceRecordBloc(
            priceDataProvider, priceDataNetworkProvider, stringProvider);
      }),
      BlocProvider<SelectedTransactionBloc>(create: (context) {
        return SelectedTransactionBloc(
            priceDataProvider, priceDataNetworkProvider, stringProvider);
      }),
      BlocProvider<DefaultNbeHoldDurationBloc>(create: (context) {
        return DefaultNbeHoldDurationBloc(stringProvider);
      }),
    ],
    child: const MyApp(),
  ));
}

MaterialColor ourMainThemeColor = MaterialColor(
  _mainThemeValue,
  <int, Color>{
    50: const Color(0xFF74C9F8),
    100: const Color(0xFF74C9F8),
    200: const Color(0xFF409dd6),
    300: const Color(0xFF248BC4),
    400: const Color(0xFF1a87da),
    500: Color(_mainThemeValue),
    600: const Color(0xFF055fab),
    700: const Color(0xFF055fab),
    800: const Color(0xFF055fab),
    900: const Color(0xFF055fab),
  },
);

int _mainThemeValue = 0xFF055fab;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<PriceRecordBloc>().add(LoadPriceRecordsEvent());
    context.read<TodaysPriceRecordBloc>().add(LoadTodaysPriceRecordsEvent());
    context.read<SettingBloc>().add(LoadLastSettingEvent());
    context
        .read<SelectedDatePriceRecordBloc>()
        .add(SelectOtherDatePriceRecordEvent(DateTime.now()));
    context.read<TransactionsBloc>().add(LoadTransactions());

    return MaterialApp(
        theme: ThemeData(
          primaryColorLight: const Color(0xFF1a87da),
          primaryColor: Color(_mainThemeValue),
          primarySwatch: ourMainThemeColor,
          // canvasColor: Colors.black,
        ),
        title: 'Gold Purchasing Rate',
        home: const NavigationController(),
        initialRoute: NavigationController.routeName, // AuthScreen.RouteName,
        onGenerateRoute: (setting) {
          switch (setting.name) {
            case TransactionViewDetails.routeName:
              {
                final arg = (setting.arguments as TransactionDetailParam);
                return MaterialPageRoute(builder: (context) {
                  return TransactionViewDetails(arg.transaction, arg.setting);
                });
              }
            case NavigationController.routeName:
              {
                return MaterialPageRoute(builder: (context) {
                  return const NavigationController();
                });
              }
          }
        });
  }
}

class NavigationController extends StatefulWidget {
  static const String routeName = "navigator/screen";
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;
  static List<Widget> widgetList = [
    const BalanceScreen(),
    const CalculatorScreen(),
    const PriceHistoryScreen(),
    const ReportScreen(),
    const SettingsScreen(nbe24KaratRate: 23432),
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
        fixedColor: Theme.of(context).primaryColor,
        // backgroundColor: const Color.fromARGB(255, 1, 28, 49),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined), label: 'Price History'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
            //dispose the snackbar of one screen when moving to the next
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          });
        },
      ),
    );
  }
}
