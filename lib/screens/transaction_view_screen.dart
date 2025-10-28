import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';

class TransactionViewDetails extends StatefulWidget {
  static const String routeName = "/view/transaction/detail";
  final Transaction transaction;
  final Setting setting;
  const TransactionViewDetails(this.transaction, this.setting, {super.key});
  @override
  State<TransactionViewDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionViewDetails> {
  int dayExtensions = 0;
  bool extendTheDays = false;

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

  @override
  Widget build(BuildContext context) {
    final defaultNBEHodDays = (context.watch<DefaultNbeHoldDurationBloc>().state
            as DefaultNbeHoldDurationLoaded)
        .days;

    final holdRate = (widget.setting.holdPercentage / 100);
    final karatRate = (widget.transaction.karat / 24);
    final bonusRate = (1 + (widget.setting.bonusByNBEInPercentage / 100));

    final totalOf95Percent = (widget.transaction.initialPrice * bonusRate) *
        karatRate *
        widget.transaction.gram *
        (1 - holdRate);

    final totalOfInitialHold =
        (widget.transaction.initialPrice * karatRate * bonusRate) *
            widget.transaction.gram *
            holdRate;

    final bankFeeof95Percent =
        totalOf95Percent * widget.setting.bankFeePercentage;

    final increase =
        ((((widget.transaction.athPrice - widget.transaction.initialPrice) *
            bonusRate *
            karatRate *
            widget.transaction.gram)));

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
                              SettingItem(widget.setting),
                            ]),
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
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        (context
                                                    .watch<
                                                        SelectedDatePriceRecordBloc>()
                                                    .state
                                                is SelectedDatePriceRecordLoaded)
                                            ? Text(
                                                'Deposit Date: ${DateFormat.yMMMMd().format((context.watch<SelectedDatePriceRecordBloc>().state as SelectedDatePriceRecordLoaded).dateTime)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : const Skeleton(
                                                width: 100, height: 10),
                                        if (context
                                                .watch<
                                                    SelectedDatePriceRecordBloc>()
                                                .state
                                            is SelectedDatePriceRecordLoaded)
                                          Text(
                                            'Settlement Date: ${DateFormat.yMMMMd().format(widget.transaction.endDate!)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          margin: const EdgeInsets.symmetric(vertical: 2),
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
                          width: MediaQuery.of(context).size.width * .9,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Checkbox(
                                        value: extendTheDays,
                                        onChanged: (val) {
                                          setState(() {
                                            extendTheDays = val!;
                                          });
                                        }),
                                  ),
                                  Expanded(
                                    flex: 9,
                                    child: Text(
                                      'Would you like to extend settlement date?',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (extendTheDays)
                                Row(
                                  children: [
                                    Text(
                                      'Extend by ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    FancyCounter(
                                      dayExtensions,
                                      (val) {
                                        setState(() {
                                          dayExtensions = val;
                                        });
                                        widget.transaction.endDate = widget
                                            .transaction.date
                                            .add(Duration(
                                                days: defaultNBEHodDays +
                                                    dayExtensions));
                                      },
                                    ),
                                    Text(
                                      'days',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const Divider(),
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
                                  "${widget.transaction.gram}",
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
                                  currencyFormatWith2DecimalValues(
                                      widget.transaction.karat),
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
                        const Divider(),
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
                                      widget.transaction.initialPrice *
                                          (1 +
                                              (widget.setting
                                                      .bonusByNBEInPercentage /
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
                                      widget.transaction.athPrice *
                                          (1 +
                                              (widget.setting
                                                      .bonusByNBEInPercentage /
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total of ${100 - widget.setting.holdPercentage} %",
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
                              "Total of ${widget.setting.holdPercentage} %",
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
                              'Bank Fee of ${100 - widget.setting.holdPercentage} %',
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
                              'Tax of ${widget.transaction.gram} gram',
                              textAlign: TextAlign.center,
                              style: _commonLabelStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  NumberFormat('#,##0').format(
                                      widget.transaction.gram *
                                          widget.setting.taxPerGram),
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
                                  currencyFormatWith2DecimalValues(((widget
                                                  .transaction.initialPrice *
                                              (1 +
                                                  (widget.setting
                                                          .bonusByNBEInPercentage /
                                                      100))) *
                                          (widget.transaction.karat / 24) *
                                          widget.transaction.gram *
                                          ((100 -
                                                  widget
                                                      .setting.holdPercentage) /
                                              100))

                                      // Bank Fee
                                      -
                                      (((widget.transaction.initialPrice *
                                                  (1 +
                                                      (widget.setting
                                                              .bonusByNBEInPercentage /
                                                          100))) *
                                              (widget.transaction.karat / 24) *
                                              widget.transaction.gram *
                                              (1 -
                                                  (widget.setting
                                                          .holdPercentage /
                                                      100))) *
                                          widget.setting.bankFeePercentage)
                                      // Tax Deduction

                                      -
                                      (widget.transaction.gram *
                                          widget.setting.taxPerGram)),
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
                                  currencyFormatWith2DecimalValues(((widget
                                                  .transaction.athPrice *
                                              (1 +
                                                  (widget.setting
                                                          .bonusByNBEInPercentage /
                                                      100))) *
                                          (widget.transaction.karat / 24) *
                                          widget.transaction.gram) -
                                      ((widget.transaction.initialPrice *
                                              (1 +
                                                  (widget.setting
                                                          .bonusByNBEInPercentage /
                                                      100))) *
                                          (widget.transaction.karat / 24) *
                                          widget.transaction.gram *
                                          ((100 -
                                                  widget
                                                      .setting.holdPercentage) /
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
                        // FancyWideButton(
                        //   "Save",
                        //   () {
                        //     context
                        //         .read<TransactionsBloc>()
                        //         .add(SaveTransactionEvent(widget.transaction));
                        //   }, //onSaveTapped,
                        //   animateOnClick: true,
                        // ),
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
