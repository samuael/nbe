import 'package:nbe/libs.dart';

class PriceItemPreviewSkeleton extends StatefulWidget {
  const PriceItemPreviewSkeleton({super.key});

  @override
  State<PriceItemPreviewSkeleton> createState() => _PriceItemPreviewState();
}

class _PriceItemPreviewState extends State<PriceItemPreviewSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    super.initState();

    _controller.addListener(() {
      _controller.loop();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Skeleton(
            width: 200,
            height: 12,
            borderRadius: 1,
          ),
          Skeleton(
            width: 100,
            height: 12,
            borderRadius: 1,
          ),
        ],
      ),
    ).animate(controller: _controller).shimmer(
        color: Colors.white,
        delay: const Duration(
          milliseconds: 400,
        ),
        duration: const Duration(seconds: 2));
  }
}
