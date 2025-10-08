import "package:nbe/libs.dart";

class Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  const Skeleton(
      {required this.width,
      required this.height,
      this.borderRadius = 16,
      super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.08),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
