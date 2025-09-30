import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nbe/libs.dart';

class FancyWideButton extends StatefulWidget {
  final String text;
  final Function onPressed;
  final bool enabled;
  final bool animateOnClick;
  final double sizeMultiplier;
  final double textSizeMultiplier;
  final double borderRadius;
  const FancyWideButton(this.text, this.onPressed,
      {super.key,
      this.enabled = true,
      this.animateOnClick = false,
      this.sizeMultiplier = 1.0,
      this.textSizeMultiplier = 1.0,
      this.borderRadius = 20});

  @override
  State<FancyWideButton> createState() => FancyWideButtonState();
}

class FancyWideButtonState extends State<FancyWideButton> {
  bool clicked = false;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.enabled) {
          return;
        }
        if (widget.animateOnClick) {
          setState(() {
            loading = true;
          });
        }
        await widget.onPressed();
        if (widget.animateOnClick) {
          setState(() {
            loading = false;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: 15, horizontal: 30 * widget.sizeMultiplier),
          decoration: BoxDecoration(
            color: widget.enabled && !loading
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColorLight.withOpacity(.5),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          width: MediaQuery.of(context).size.width * .8 * widget.sizeMultiplier,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.animateOnClick && loading)
                SpinKitWave(
                  color: Colors.white,
                  size: 20.0 *
                      (widget.sizeMultiplier +
                          (widget.sizeMultiplier < .5 ? .2 : 0)),
                ),
              if (widget.animateOnClick && loading) const SizedBox(width: 10),
              Text(
                widget.text,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14 * widget.textSizeMultiplier,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
