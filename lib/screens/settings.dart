// import 'package:nbe/screens/screens.dart';
import 'package:nbe/libs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          children: [
            CommonTextField(
                label: 'Immediate Payment Amount',
                onChanged: (val) {},
                errorMessage: ''),
            CommonTextField(
                label: 'Tax per Gram', onChanged: (val) {}, errorMessage: ''),
            CommonTextField(
                label: 'Bank Fee in Percent',
                onChanged: (val) {},
                errorMessage: ''),
            CommonTextField(
                label: 'Bonus by NBE', onChanged: (val) {}, errorMessage: ''),
            const SizedBox(
              height: 24,
            ),
            FancyWideButton('Save', () {})
          ],
        ),
      ),
    );
  }
}
