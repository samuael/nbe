import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';

class CalculationDetails extends StatefulWidget {
  CalculationDetails({super.key});
  @override
  State<CalculationDetails> createState() => _CalculationDetailsState();
}

class _CalculationDetailsState extends State<CalculationDetails> {
  final _remainingController = TextEditingController();

  final TextStyle _commonLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black.withValues(alpha: .5),
    overflow: TextOverflow.visible,
  );

  //to check if the day has changed
  bool areSameDates(DateTime day1, DateTime day2) {
    return day1.toIso8601String().substring(0, 10) ==
        day2.toIso8601String().substring(0, 10);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(days: 1),
        content: Text(message),
        action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              // _getPurchasingRate();
              // _getSettings();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
      ),
    );
  }

  @override
  void initState() {
    // calculateValues();
    super.initState();
  }

  late Transaction transaction;
  late Setting setting;
  late PriceRecord selectedDatePriceRecord;

  final TextStyle _labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    overflow: TextOverflow.visible,
  );

  @override
  Widget build(BuildContext context) {
    if (context.watch<SelectedTransactionBloc>().state
        is! TransactionSelected) {
      throw Exception("transaction not found");
    }

    transaction =
        (context.watch<SelectedTransactionBloc>().state as TransactionSelected)
            .transaction;

    setting = (context.watch<SettingBloc>().state as SettingLoaded).setting;

    selectedDatePriceRecord = (context
            .watch<SelectedDatePriceRecordBloc>()
            .state as SelectedDatePriceRecordLoaded)
        .record
        .get24KaratRecord()!;

    final athPriceRecord = context
        .watch<PriceRecordBloc>()
        .getATHPriceRecord(selectedDatePriceRecord.date!);

    transaction.initialPrice = selectedDatePriceRecord.priceBirr!;
    transaction.athPrice = athPriceRecord!.priceBirr!;
    transaction.settingID = setting.id;
    transaction.setting = setting;
    transaction.initialPriceRecord = selectedDatePriceRecord;

    final holdRate = (setting.holdPercentage / 100);
    final karatRate = (transaction.karat / 24);
    final bonusRate = (1 + (setting.bonusByNBEInPercentage / 100));

    final totalOf95Percent = (transaction.initialPrice * bonusRate) *
        karatRate *
        transaction.gram *
        (1 - holdRate);

    final totalOfInitialHold =
        (transaction.initialPrice * karatRate * bonusRate) *
            transaction.gram *
            holdRate;

    final bankFeeof95Percent = totalOf95Percent * setting.bankFeePercentage;

    final increase = ((((transaction.athPrice - transaction.initialPrice) *
        bonusRate *
        karatRate *
        transaction.gram)));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculation Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .9,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: const BorderSide(color: Colors.orange),
                          right: const BorderSide(color: Colors.orange),
                          bottom: BorderSide(
                            color: Colors.black.withValues(alpha: .05),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      width: MediaQuery.of(context).size.width * .9,
                      height: MediaQuery.of(context).size.height * .15,
                      child: Stack(
                        children: [
                          // if (settingLoad.state is SettingLoaded)
                          SingleChildScrollView(
                            child: TitledContainer("Settings", [
                              SettingItem(setting),
                            ]),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: () async {
                                final Setting? newSetting = await Navigator.of(
                                        context)
                                    .push(MaterialPageRoute(
                                        builder: (ctx) => const SettingsScreen(
                                            // nbe24KaratRate: double.tryParse(
                                            //         pricesMap['24'] ?? '') ??
                                            nbe24KaratRate: 0)));

                                if (newSetting != null) {
                                  setState(() {
                                    setting = newSetting;
                                  });
                                }
                              },
                              splashColor: Theme.of(context).primaryColor,
                              icon: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: .5)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                      size: 14,
                                    )
                                  ],
                                ),
                              ),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    flex: 8,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(children: [
                                  (context
                                          .watch<SelectedDatePriceRecordBloc>()
                                          .state is SelectedDatePriceRecordLoaded)
                                      ? Text(
                                          'Date: ${DateFormat.yMMMMd().format((context.watch<SelectedDatePriceRecordBloc>().state as SelectedDatePriceRecordLoaded).dateTime)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : const Skeleton(width: 100, height: 10),
                                ]),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Weight",
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  "${transaction.gram}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Gram",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Karat",
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  "${transaction.karat}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Karat",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Initial Price",
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  currencyFormatWith2DecimalValues(
                                      transaction.initialPrice),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "BIRR",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "All Time Hight Price",
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  currencyFormatWith2DecimalValues(
                                      transaction.athPrice),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "BIRR",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total of ${100 - setting.holdPercentage} %",
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  currencyFormatWith2DecimalValues(
                                      totalOf95Percent),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "BIRR",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total of ${setting.holdPercentage} %",
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  currencyFormatWith2DecimalValues(
                                      totalOfInitialHold),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "BIRR",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bank Fee of ${100 - setting.holdPercentage} %',
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  currencyFormatWith2DecimalValues(
                                      bankFeeof95Percent),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "BIRR",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tax of ${transaction.gram} gram',
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  NumberFormat('#,##0').format(
                                      transaction.gram * setting.taxPerGram),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "BIRR",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Increase',
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  currencyFormatWith2DecimalValues(increase),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "BIRR",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Net',
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  currencyFormatWith2DecimalValues(
                                      ((selectedDatePriceRecord.priceBirr! *
                                                  (1 +
                                                      (setting.bonusByNBEInPercentage /
                                                          100))) *
                                              (transaction.karat / 24) *
                                              transaction.gram *
                                              ((100 - setting.holdPercentage) /
                                                  100))

                                          // Bank Fee
                                          -
                                          (((selectedDatePriceRecord
                                                          .priceBirr! *
                                                      (1 +
                                                          (setting.bonusByNBEInPercentage /
                                                              100))) *
                                                  (transaction.karat / 24) *
                                                  transaction.gram *
                                                  (1 -
                                                      (setting.holdPercentage /
                                                          100))) *
                                              setting.bankFeePercentage)
                                          // Tax Deduction

                                          -
                                          (transaction.gram *
                                              setting.taxPerGram)),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "BIRR",
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
                        const Divider(),
                        if (athPriceRecord != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Remaining',
                                textAlign: TextAlign.center,
                                style: _commonLabelStyle,
                              ),
                              Row(
                                children: [
                                  Text(
                                    // Increase
                                    currencyFormatWith2DecimalValues(((athPriceRecord
                                                    .priceBirr! *
                                                (1 +
                                                    (setting.bonusByNBEInPercentage /
                                                        100))) *
                                            (transaction.karat / 24) *
                                            transaction.gram) -
                                        ((selectedDatePriceRecord.priceBirr! *
                                                (1 +
                                                    (setting.bonusByNBEInPercentage /
                                                        100))) *
                                            (transaction.karat / 24) *
                                            transaction.gram *
                                            ((100 - setting.holdPercentage) /
                                                100))),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "BIRR",
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
                        const Divider(),
                        const SizedBox(
                          height: 12,
                        ),
                        FancyWideButton(
                          "Save",
                          () {
                            context
                                .read<TransactionsBloc>()
                                .add(SaveTransactionEvent(transaction));
                          }, //onSaveTapped,
                          animateOnClick: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
