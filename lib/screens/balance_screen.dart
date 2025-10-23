import 'package:nbe/libs.dart';

class BalanceScreen extends StatefulWidget {
  static const String routeName = "/balance/home/screen";
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  bool showAllKaratValues = true;

  final TextStyle _commonLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black.withValues(alpha: .5),
    overflow: TextOverflow.visible,
  );

  @override
  Widget build(BuildContext context) {
    final Container _tinyDivider = Container(
      color: Colors.amber.withValues(alpha: .1),
      width: MediaQuery.of(context).size.width * .5,
      height: 0.5,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * .9,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.orange),
                right: BorderSide(color: Colors.orange),
              ),
            ),
            // padding: const EdgeInsets.symmetric(horizontal: 10.0),
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
            child: TitledContainer(
              'Today\'s National Bank Rate',
              (showAllKaratValues
                      ? ["24", "23", "22", "21", "20", "19", "18", "16"]
                      : [
                          "24",
                        ])
                  .map<Column>((k) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '$k Karrat',
                          textAlign: TextAlign.center,
                          style: k == "24"
                              ? TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black.withValues(alpha: .8),
                                  overflow: TextOverflow.visible,
                                )
                              : _commonLabelStyle,
                        ),
                        (context.watch<TodaysPriceRecordBloc>().state
                                is! TodayPriceRecordsLoaded)
                            ? const ShimmerSkeleton(
                                width: 50,
                                height: 10,
                                borderRadius: 2,
                              )
                            : Row(
                                children: [
                                  Text(
                                    currencyFormatter((context
                                            .watch<TodaysPriceRecordBloc>()
                                            .state as TodayPriceRecordsLoaded)
                                        .getPriceRecordByGoldKarat(k)!
                                        .priceBirr!),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'ብር/ ግራም ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withValues(alpha: .5),
                                    ),
                                  )
                                ],
                              ),
                      ],
                    ),
                    _tinyDivider,
                  ],
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.orange),
                right: BorderSide(color: Colors.orange),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 13,
                  child: Text(
                    '24 Karat After ${(context.watch<SettingBloc>().state as SettingLoaded).setting.bonusByNBEInPercentage}% Bonus ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: ((context.watch<SettingBloc>().state
                              is SettingLoaded) &&
                          (context.watch<TodaysPriceRecordBloc>().state
                              is TodayPriceRecordsLoaded))
                      ? Row(
                          children: [
                            Text(
                              currencyFormatter(((context
                                                  .watch<SettingBloc>()
                                                  .state as SettingLoaded)
                                              .setting
                                              .bonusByNBEInPercentage /
                                          100 +
                                      1) *
                                  (context.watch<TodaysPriceRecordBloc>().state
                                          as TodayPriceRecordsLoaded)
                                      .response
                                      .get24KaratRecord()!
                                      .priceBirr!),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black.withValues(alpha: .7),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'ብር/ ግራም ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withValues(alpha: .5),
                              ),
                            ),
                          ],
                        )
                      : const ShimmerSkeleton(width: 100, height: 10),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Checkbox(
                  value: showAllKaratValues,
                  onChanged: (val) {
                    setState(() {
                      showAllKaratValues = val ?? false;
                    });
                  }),
              Text(
                "Show all karat prices",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: .5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
