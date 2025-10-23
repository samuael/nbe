import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';

class PriceItemPreview extends StatefulWidget {
  final PriceRecord record;
  final bool highestPrice;
  final double bonusPercentage;
  const PriceItemPreview(this.record,
      {this.highestPrice = false, this.bonusPercentage = 0, super.key});

  @override
  State<PriceItemPreview> createState() => _PriceItemPreviewState();
}

class _PriceItemPreviewState extends State<PriceItemPreview> {
  @override
  Widget build(BuildContext context) {
    final theDate = DateTime.parse(widget.record.date!);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: widget.highestPrice ? 5 : 1,
          ),
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: .1),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            // margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(theDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    NumberFormat('#,##0.##').format(widget.record.priceBirr! *
                        (1 + (widget.bonusPercentage / 100))),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.highestPrice)
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  // bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Text(
                "Highest Price of 30 days",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
        ],
      ),
    );
  }
}
