// import 'package:nbe/screens/screens.dart';
import 'package:nbe/libs.dart';

class SettingsScreen extends StatefulWidget {
  final double nbe24KaratRate;
  const SettingsScreen({super.key, required this.nbe24KaratRate});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController immediatePaymentController =
      TextEditingController(text: '95');
  final TextEditingController taxController =
      TextEditingController(text: '5000');
  final TextEditingController bankFeeController =
      TextEditingController(text: '0.01');
  final TextEditingController bonusController =
      TextEditingController(text: '10');

  Widget _createPrefixWidget(IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 7, 0),
      child: Icon(
        icon,
        size: 17,
      ),
    );
  }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            const NotificationMessage(
                "Re-Configure your settings according to your calculation"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
              child: CommonTextField(
                borderRadius: 5,
                prefix: const Text('%      '),
                controller: immediatePaymentController,
                label: 'Immediate Payment Amount',
                onChanged: (val) {},
                errorMessage: '',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
              child: CommonTextField(
                  borderRadius: 5,
                  controller: taxController,
                  prefix: const Text('BIRR '),
                  label: 'Tax per Gram',
                  onChanged: (val) {},
                  errorMessage: ''),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
              child: CommonTextField(
                  borderRadius: 5,
                  controller: bankFeeController,
                  prefix: const Text('%      '),
                  label: 'Bank Fee in Percent',
                  onChanged: (val) {},
                  errorMessage: ''),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
              child: CommonTextField(
                  borderRadius: 5,
                  controller: bonusController,
                  prefix: const Text('%      '),
                  label: 'Bonus by NBE',
                  onChanged: (val) {},
                  errorMessage: ''),
            ),
            const SizedBox(
              height: 24,
            ),
            FancyWideButton('Save', () {
              final tax = double.tryParse(taxController.text) ?? 0;
              final bankFee = double.tryParse(bankFeeController.text) ?? 0;
              final bonus = double.tryParse(bonusController.text) ?? 0;
              final setting = Setting(
                uuid.v4(),
                widget.nbe24KaratRate,
                tax,
                bankFee / 100,
                bonus / 100,
              );
              Navigator.of(context).pop(setting);
            })
          ],
        ),
      ),
    );
  }
}
