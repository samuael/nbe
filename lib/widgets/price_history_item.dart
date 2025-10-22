import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';

class PriceItemPreview extends StatefulWidget {
  final PriceRecord record;
  final bool highestPrice;
  const PriceItemPreview(this.record, {this.highestPrice = false, super.key});

  @override
  State<PriceItemPreview> createState() => _PriceItemPreviewState();

  static Widget skeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.black.withValues(alpha: .1),
            width: 2,
          ),
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: .1),
          ),
        ),
      ),
      child: const Row(
        children: [
          Skeleton(width: 100, height: 40),
          Skeleton(width: 100, height: 40),
        ],
      ),
    );
  }
}

class _PriceItemPreviewState extends State<PriceItemPreview> {
  @override
  Widget build(BuildContext context) {
    final theDate = DateTime.parse(widget.record.date!);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
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
              NumberFormat('#,##0.##')
                  .format(double.parse(widget.record.priceBirr!)),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
