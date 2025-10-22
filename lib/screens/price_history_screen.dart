import "package:nbe/libs.dart";

class PriceHistoryScreen extends StatefulWidget {
  static const String routeName = "price/history/screen";
  const PriceHistoryScreen({super.key});

  @override
  State<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends State<PriceHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '24 Karat Price History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<PriceRecordBloc, PriceRecordState>(
          builder: (context, state) {
        switch (state.runtimeType) {
          case PriceRecordsLoaded:
            double highest = 0.0;
            String highestString = "";
            for (var el in (state as PriceRecordsLoaded).records) {
              final val = double.parse(el.priceBirr!);
              if (val > highest) {
                highest = val;
                highestString = el.priceBirr!;
              }
            }
            return Column(
                children: (state as PriceRecordsLoaded).records.map((el) {
              return PriceItemPreview(
                el,
                highestPrice: el.priceBirr == highestString,
              );
            }).toList());
          case PriceRecordsLoadFailed:
            return priceRecordsLoadingWasNotSuccesful(context);
          default:
            return Column(
              children: [
                PriceItemPreview.skeleton(),
                PriceItemPreview.skeleton(),
                PriceItemPreview.skeleton(),
                PriceItemPreview.skeleton(),
              ],
            );
        }
      }),
    );
  }

  Widget priceRecordsLoadingWasNotSuccesful(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            "😅",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.black45.withValues(alpha: .1),
            ),
          ),
        ),
        Text(
          "Price history loading failed!",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: .5),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<PriceRecordBloc>().add(LoadPriceRecordsEvent());
          },
          icon: Icon(
            Icons.replay_outlined,
            color: Colors.black.withValues(alpha: .8),
          ),
        )
      ],
    );
  }
}
