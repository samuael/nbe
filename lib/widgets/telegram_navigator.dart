import 'package:flutter/material.dart';

class TelegramNavigator extends StatefulWidget {
  // final List<IconData> icons;
  final List<int>? notificationCounts;
  final List<String> titles;
  final double? height;
  final Function onChange;
  final Function getStage;
  final bool bigFonts;
  final List<Widget> widgets;
  final bool showTitleWhenSelectedOnly;
  final Color? backgroundColor;
  final Color? elementsColor;
  final double? width;

  const TelegramNavigator(
    this.onChange,
    this.getStage, {
    super.key,
    // required this.icons,
    required this.titles,
    this.notificationCounts,
    this.height,
    this.bigFonts = false,
    this.widgets = const [],
    this.showTitleWhenSelectedOnly = false,
    this.backgroundColor,
    this.elementsColor,
    this.width,
  });

  @override
  State<TelegramNavigator> createState() => _TelegramNavigatorState();
}

class _TelegramNavigatorState extends State<TelegramNavigator> {
  double notificationEntries = 0;
  double totalTitlesLen = 0;
  late List<double> proportions;
  late List<double> distances;

  @override
  void initState() {
    super.initState();

    widget.notificationCounts?.forEach((e) {
      if (e > 0) {
        notificationEntries += 2;
      }
    });

    totalTitlesLen = widget.titles.join("").length + notificationEntries;

    proportions = widget.titles.asMap().entries.map<double>((elem) {
      return ((widget.titles[elem.key].length +
              ((widget.notificationCounts != null &&
                      widget.notificationCounts![elem.key] > 0)
                  ? 2
                  : 0)) /
          totalTitlesLen);
    }).toList();

    distances = proportions.asMap().entries.map<double>((elem) {
      double distance = 0;
      proportions.sublist(0, elem.key).forEach((e) {
        distance += e;
      });
      return distance;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width ?? MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.widgets.asMap().entries.map((elem) {
              return GestureDetector(
                onTap: () {
                  widget.onChange(elem.key);
                },
                child: SizedBox(
                  height: 20,
                  width: (widget.width ??
                      MediaQuery.of(context).size.width) * proportions[elem.key],
                  child: widget.showTitleWhenSelectedOnly &&
                          widget.notificationCounts![elem.key] > 0
                      ? Row(
                          mainAxisSize: widget.bigFonts
                              ? MainAxisSize.max
                              : MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            elem.value,
                            CircleAvatar(
                              maxRadius: 8,
                              minRadius: 8,
                              backgroundColor: Colors.red[400],
                              child: Text(
                                "${widget.notificationCounts![elem.key]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          ],
                        )
                      : elem.value,
                ),
              );
            }).toList(),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.titles.asMap().entries.map((elem) {
                return GestureDetector(
                  onTap: () {
                    widget.onChange(elem.key);
                  },
                  child: Container(
                    width: (widget.width ??
                        MediaQuery.of(context).size.width) *
                            proportions[elem.key],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                    child: Row(
                      mainAxisSize:
                          widget.bigFonts ? MainAxisSize.max : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          elem.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: widget.bigFonts ? 15 : 13,
                            fontWeight: widget.getStage() == elem.key
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: widget.getStage() == elem.key
                                ? Theme.of(context).primaryColor
                                : Colors.black.withOpacity(.4),
                          ),
                        ),
                        if (widget.notificationCounts != null &&
                            widget.notificationCounts![elem.key] > 0)
                          SizedBox(width: widget.bigFonts ? 10 : 2),
                        if (widget.notificationCounts != null &&
                            widget.notificationCounts![elem.key] > 0 &&
                            widget.widgets.isEmpty)
                          CircleAvatar(
                            maxRadius: 10,
                            minRadius: 10,
                            backgroundColor: Colors.red[400],
                            child: Text(
                              "${widget.notificationCounts![elem.key]}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (widget.width ?? MediaQuery.of(context).size.width) *
                    distances[widget.getStage()],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 5,
                width:
                    ((widget.width ?? MediaQuery.of(context).size.width) * .9) *
                        proportions[widget.getStage()],
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
              ),
              const SizedBox()
            ],
          )
        ],
      ),
    );
  }
}
