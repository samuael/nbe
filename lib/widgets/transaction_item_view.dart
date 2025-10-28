import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';

class TransactionItemView extends StatefulWidget {
  final Transaction transaction;
  final bool selecting;
  final void Function(String id) onSelect;
  final bool Function(String id) isSelected;
  const TransactionItemView(this.transaction,
      {required this.onSelect,
      required this.isSelected,
      this.selecting = false,
      super.key});

  @override
  State<TransactionItemView> createState() => _TransactionItemViewState();
}

class _TransactionItemViewState extends State<TransactionItemView> {
  @override
  Widget build(BuildContext context) {
    final increase =
        ((((widget.transaction.athPrice - widget.transaction.initialPrice) *
            1.15 *
            (widget.transaction.karat / 24) *
            widget.transaction.gram)));
    Setting? setting;
    context
        .watch<SettingsBloc>()
        .getSettingByID(widget.transaction.settingID)
        .then((sett) {
      setting = sett;
    });

    return GestureDetector(
      onTap: widget.selecting
          ? () => widget.onSelect(widget.transaction.id)
          : () {
              if (setting != null) {
                Navigator.of(context).pushNamed(
                  TransactionViewDetails.routeName,
                  arguments: TransactionDetailParam(
                    widget.transaction,
                    setting!,
                  ),
                );
              }
            },
      onLongPress: () => widget.onSelect(widget.transaction.id),
      child: Stack(children: [
        if (widget.selecting)
          Positioned(
            top: 0,
            bottom: 0,
            child: Icon(
              Icons.check_box,
              color: widget.isSelected(widget.transaction.id)
                  ? Theme.of(context).primaryColorLight
                  : Colors.black.withValues(alpha: .1),
              size: 18,
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withValues(alpha: .1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(flex: 5, child: SizedBox()),
                  Expanded(
                      flex: 20,
                      child: Row(
                        children: [
                          Text(
                            widget.transaction.gram.toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'g',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: .4),
                            ),
                          ),
                        ],
                      )),
                  Expanded(
                    flex: 30,
                    child: Row(
                      children: [
                        Text(
                          currencyFormatWith2DecimalValues(
                              widget.transaction.karat),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' karat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black45.withValues(alpha: .5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.transaction.isCompleted)
                    Expanded(
                      flex: 35,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: increase > 0
                                ? Colors.green
                                : Colors.black.withValues(alpha: .5),
                            size: 14,
                          ),
                          Text(
                            currencyFormatWith2DecimalValues(increase),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: increase > 0
                                  ? Colors.green
                                  : Colors.black.withValues(alpha: .5),
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        ],
                      ),
                    ),
                  if (widget.transaction.isCompleted)
                    Expanded(
                      flex: 35,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 15,
                          ),
                          Text(
                            widget.transaction.isCompleted
                                ? 'Completed'
                                : 'Pending',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .03),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Text(
                            "Deposit Date:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: .4),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat.MMMd().format(widget.transaction.date),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Text(
                            "Settlement Date:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: .4),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat.MMMd()
                                .format(widget.transaction.endDate!),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
