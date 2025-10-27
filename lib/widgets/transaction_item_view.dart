import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';

class TransactionItemView extends StatefulWidget {
  final Transaction transaction;
  const TransactionItemView(this.transaction, {super.key});

  @override
  State<TransactionItemView> createState() => _TransactionItemViewState();
}

class _TransactionItemViewState extends State<TransactionItemView> {
  @override
  Widget build(BuildContext context) {
    final increase =
        ((((widget.transaction.athPrice - widget.transaction.initialPrice) *
            1.15 *
            widget.transaction.karat *
            widget.transaction.gram)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1,
          ),
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: .1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 20,
                child: Text(
                  DateFormat.MMMd().format(
                    DateTime.fromMillisecondsSinceEpoch(
                        widget.transaction.createdAt * 1000),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                  flex: 25,
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
                flex: 35,
                child: Row(
                  children: [
                    Text(
                      '${widget.transaction.karat} ',
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
          Row(
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
                DateFormat.MMMd().format(widget.transaction.endDate!),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
