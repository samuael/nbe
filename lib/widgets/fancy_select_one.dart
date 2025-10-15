import 'package:nbe/libs.dart';

Widget fancySelectOneWidget(
  BuildContext context,
  int id,
  String name,
  Function onClicked,
  Function getState, {
  bool isFirstElement = false,
  bool isLastElement = false,
  enableCheck = true,
  Widget? child,
  double heightMultiplier = 1.0,
  double widthMultiplier = 1.0,
  bool disabled = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    child: GestureDetector(
      onTap: disabled ? null : () => onClicked(id),
      child: Builder(
        builder: (context) {
          // Define reusable variables
          final isSelected = getState() == id;
          final containerColor = isSelected
              ? Theme.of(context).primaryColorLight
              : (disabled
                  ? Colors.grey.withOpacity(0.5)
                  : Theme.of(context).primaryColorLight.withOpacity(.05));
          final textColor = isSelected
              ? Colors.white
              : (disabled
                  ? Theme.of(context).primaryColor.withOpacity(0.5)
                  : Theme.of(context).primaryColor);
          final borderColor = disabled
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(.05);
          final borderRadius = isFirstElement
              ? const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                )
              : (isLastElement
                  ? const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )
                  : BorderRadius.circular(10));

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.0 * widthMultiplier,
              vertical: 5.0 * heightMultiplier,
            ),
            decoration: BoxDecoration(
              color: containerColor,
              border: Border.all(color: borderColor),
              borderRadius: borderRadius,
            ),
            child: Row(
              children: [
                if (isSelected && enableCheck)
                  const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 5),
                child ?? const SizedBox(),
                const SizedBox(width: 10),
                Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    color: textColor.withOpacity(.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
