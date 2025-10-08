import 'package:nbe/libs.dart';
export 'package:flutter_animate/flutter_animate.dart';

class ShimmerSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  const ShimmerSkeleton(
      {required this.width,
      required this.height,
      this.borderRadius = 16,
      super.key});

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
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
    return SizedBox(
      // duration: Duration(milliseconds: 400),
      child: Skeleton(
        width: widget.width,
        height: widget.height,
        borderRadius: widget.borderRadius,
      ),
    ).animate(controller: _controller).shimmer(
        color: Colors.white,
        delay: const Duration(
          milliseconds: 400,
        ),
        duration: const Duration(seconds: 2));
  }
}
