import "package:nbe/libs.dart";

class FancyCounter extends StatefulWidget {
  final int min;
  final int max;
  final int initialValue;
  final bool enabled;
  final void Function(int) onChange;
  const FancyCounter(this.initialValue, this.onChange,
      {this.min = 0, this.max = 1000, this.enabled = true, super.key});

  @override
  State<FancyCounter> createState() => _FancyCounterState();
}

class _FancyCounterState extends State<FancyCounter> {
  late int quantity;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialValue;
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      margin: const EdgeInsets.symmetric(vertical: 2),
      width: MediaQuery.of(context).size.width * .4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.enabled)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: CircleBorder(
                        side: BorderSide(
                      color: Colors.black.withOpacity(.1),
                    )),
                  ),
                  onPressed: () {
                    if (quantity <= widget.min) {
                      return;
                    }
                    setState(() {
                      quantity -= 1;
                      controller.text = "$quantity";
                      widget.onChange(quantity);
                    });
                  },
                  child: const Icon(Icons.remove, size: 18),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "$quantity",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
              if (widget.enabled)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    foregroundColor: Colors.black.withValues(alpha: .5),
                  ),
                  onPressed: () {
                    if (quantity >= widget.max) {
                      return;
                    }
                    setState(() {
                      quantity += 1;
                      controller.text = "$quantity";
                      widget.onChange(quantity);
                    });
                  },
                  child: Icon(Icons.add,
                      size: 18, color: Colors.black.withValues(alpha: .5)),
                ),
            ],
          ),
          // GestureDetector(
          //   onTap: () {
          //     if (quantity <= widget.min) {
          //       return;
          //     }
          //     setState(() {
          //       quantity -= 1;
          //       controller.text = "$quantity";
          //       widget.onChange(quantity);
          //     });
          //   },
          //   child: Container(
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         color: Theme.of(context).primaryColorLight,
          //       ),
          //       borderRadius: BorderRadius.circular(15),
          //     ),
          //     padding: const EdgeInsets.all(2),
          //     child: const Icon(FontAwesomeIcons.minus),
          //   ),
          // ),
          // Text(
          //   "$quantity",
          //   style: const TextStyle(
          //     fontWeight: FontWeight.w600,
          //     fontSize: 20,
          //   ),
          // ),
          // // SizedBox(
          // //     height: 20,
          // //     width: 20,
          // //     child: TextField(
          // //       controller: controller,
          // //       keyboardType: TextInputType.number,
          // //       decoration: InputDecoration(
          // //         border: OutlineInputBorder(
          // //           borderRadius: BorderRadius.circular(20),
          // //         ),
          // //       ),
          // //       onChanged: (value) {
          // //         if value ==
          // //       },
          // //     )),
          // GestureDetector(
          //   onTap: () {
          //     if (quantity >= widget.max) {
          //       return;
          //     }
          //     setState(() {
          //       quantity += 1;
          //       controller.text = "$quantity";
          //       widget.onChange(quantity);
          //     });
          //   },
          //   child: Container(
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         color: Theme.of(context).primaryColorLight,
          //       ),
          //       borderRadius: BorderRadius.circular(15),
          //     ),
          //     padding: const EdgeInsets.all(2),
          //     child: const Icon(Icons.add),
          //   ),
          // ),
        ],
      ),
    );
  }
}
