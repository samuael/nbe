import 'package:nbe/libs.dart';

class SettingItem extends StatelessWidget {
  final Setting setting;
  final bool quoted;
  SettingItem(this.setting, {this.quoted = false, super.key});

  final TextStyle _commonLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black.withValues(alpha: .5),
    overflow: TextOverflow.visible,
  );

  final TextStyle _commonValuesStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    overflow: TextOverflow.visible,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SettingBloc>().add(SelectSettingByIDEvent(setting.id));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black.withValues(alpha: .05),
            ),
            left: BorderSide(
              width: quoted ? 5 : 1,
              color: Theme.of(context).primaryColor.withValues(alpha: 1),
            ),
            right: BorderSide(
              width: 1,
              color: Theme.of(context).primaryColor.withValues(alpha: 1),
            ),
          ),
        ),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Immediate Payment Amount ',
                  style: _commonLabelStyle,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${100 - setting.holdPercentage}%',
                  style: _commonValuesStyle,
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                flex: 2,
                child: Text('Tax per gram', style: _commonLabelStyle),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${setting.taxPerGram} Birr',
                  style: _commonValuesStyle,
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                flex: 2,
                child: Text('Bank Fee in percent:', style: _commonLabelStyle),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${setting.bankFeePercentage * 100}%',
                  style: _commonValuesStyle,
                ),
              ),
            ]),
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Bonus by NBE:', style: _commonLabelStyle)),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${setting.bonusByNBEInPercentage}%',
                    style: _commonValuesStyle,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
