import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nbe/libs.dart';

class CurrentSetting extends StatefulWidget {
  const CurrentSetting({super.key});

  @override
  State<CurrentSetting> createState() => _CurrentSettingState();
}

class _CurrentSettingState extends State<CurrentSetting> {
  Setting? setting;

  final TextEditingController taxController = TextEditingController();
  final TextEditingController bankFeeController = TextEditingController();
  final TextEditingController nbeTemporaryController = TextEditingController();
  final TextEditingController bonusController = TextEditingController();

  bool once = true;

  @override
  Widget build(BuildContext context) {
    context.read<SettingBloc>().add(LoadLastSettingEvent());

    return BlocBuilder<SettingBloc, SettingState>(builder: (context, state) {
      switch (state.runtimeType) {
        case SettingInit:
          return SizedBox(
            child: Column(
              children: [
                SpinKitWanderingCubes(
                  color: Theme.of(context).primaryColor,
                ),
                const Text(
                  "Setting Loading ... ",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        case SettingLoaded:
          setting = (state as SettingLoaded).setting;

          if (setting != null && once) {
            taxController.text = "${setting!.taxPerGram}";
            bankFeeController.text = "${setting!.bankFeePercentage}";
            nbeTemporaryController.text = "${setting!.holdPercentage}";
            bonusController.text = "${setting!.bonusByNBEInPercentage}";
            once = false;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              children: [
                const NotificationMessage(
                    "Re-Configure your settings according to your calculation"),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                  child: CommonTextField(
                      borderRadius: 5,
                      controller: taxController,
                      prefix: const Text('BIRR '),
                      label: 'Tax per Gram',
                      onChanged: (val) {},
                      errorMessage: ''),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                  child: CommonTextField(
                      borderRadius: 5,
                      controller: nbeTemporaryController,
                      prefix: const Text('%      '),
                      label: 'NBE Temporary Hold Percent',
                      onChanged: (val) {},
                      errorMessage: ''),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                  child: CommonTextField(
                      borderRadius: 5,
                      controller: bankFeeController,
                      prefix: const Text('%      '),
                      label: 'Bank Fee in Percent',
                      onChanged: (val) {},
                      errorMessage: ''),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
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
                  final holdPercentage =
                      double.tryParse(nbeTemporaryController.text) ?? 0;
                  final setting = Setting(
                    "${DateTime.now().millisecondsSinceEpoch}",
                    tax,
                    bankFee,
                    holdPercentage,
                    bonus,
                  );
                  context.read<SettingBloc>().add(UpdateSettingEvent(setting));
                })
              ],
            ),
          );
        default:
          return SizedBox(
            child: Column(
              children: [
                SpinKitWanderingCubes(
                  color: Theme.of(context).primaryColor,
                ),
                const Text(
                  "Setting Loading ... ",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
      }
    });
  }
}
