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
    context.read<PriceRecordBloc>().add(LoadPriceRecordsEvent());

    final setting =
        (context.watch<SettingBloc>().state as SettingLoaded).setting;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '24 Karat Price History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PriceRecordBloc>().add(ShowTheLoadedEvent());
            },
            icon: Icon(
              Icons.replay_outlined,
              color: Colors.black.withValues(alpha: .8),
            ),
          )
        ],
      ),
      body: BlocBuilder<PriceRecordBloc, PriceRecordState>(
          builder: (context, state) {
        switch (state.runtimeType) {
          case PriceRecordsLoaded:
            double highest = 0.0;
            for (var el in (state as PriceRecordsLoaded).records) {
              final val = el.priceBirr!;
              if (val > highest) {
                highest = val;
              }
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                    children: state.records.map((el) {
                  return PriceItemPreview(
                    el,
                    highestPrice: el.priceBirr == highest,
                    bonusPercentage: setting.bonusByNBEInPercentage,
                  );
                }).toList()),
              ),
            );
          case PriceRecordsLoadFailed:
            return priceRecordsLoadingWasNotSuccesful(context);
          default:
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(16, (el) {
                    return const PriceItemPreviewSkeleton();
                  }),
                ),
              ),
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
