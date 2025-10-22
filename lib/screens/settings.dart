import 'package:nbe/libs.dart';

class SettingsScreen extends StatefulWidget {
  final double nbe24KaratRate;
  const SettingsScreen({super.key, required this.nbe24KaratRate});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PageController _pageController = PageController();

  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            flex: 5,
            child: TelegramNavigator(
              (int index) {
                setState(() {
                  pageIndex = index;
                  _pageController.animateToPage(pageIndex,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn);
                });
              },
              () {
                return pageIndex;
              },
              titles: const ["Current Setting", "Setting History"],
            ),
          ),
          Expanded(
            flex: 75,
            child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  pageIndex = index;
                });
              },
              children: const [
                CurrentSetting(),
                SettingsPage(),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
