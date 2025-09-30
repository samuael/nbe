import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:nbe/libs.dart";

class CommonTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextStyle? hintStyle;
  final String errorMessage;
  final TextEditingController? controller;
  final Function onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final bool canBeObsecured;
  final bool isObsecured;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final TextAlign textAlign;
  final bool enabled;
  final double? borderRadius;
  const CommonTextField(
      {required this.onChanged,
      required this.errorMessage,
      this.prefix,
      this.suffix,
      this.label,
      this.hintText,
      this.hintStyle,
      this.controller,
      this.canBeObsecured = false,
      this.isObsecured = true,
      this.keyboardType = TextInputType.text,
      this.maxLines = 1,
      this.minLines = 1,
      this.textAlign = TextAlign.start,
      this.enabled = true,
      this.borderRadius,
      super.key});

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late bool obsecurePassword;
  @override
  void initState() {
    obsecurePassword = widget.isObsecured;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black38.withOpacity(.05),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
      ),
      child: TextField(
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        cursorColor: Colors.black38,
        cursorHeight: 20,
        controller: widget.controller,
        textAlign: widget.textAlign,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        obscureText: widget.canBeObsecured ? obsecurePassword : false,
        decoration: InputDecoration(
          errorText: widget.errorMessage == "" ? null : widget.errorMessage,
          errorMaxLines: 3,
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w400,
            fontSize: 16,
            overflow: TextOverflow.visible,
          ),
          // errorBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(20),
          //   borderSide: BorderSide(
          //     style: BorderStyle.none,
          //     color: Colors.redAccent.withOpacity(.1),
          //     width: .05,
          //   ),
          // ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Theme.of(context).primaryColor,
              width: .2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
            borderSide: const BorderSide(
              style: BorderStyle.solid,
              color: Colors.black38,
              width: .2,
            ),
          ),
          labelText: widget.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ??
              const TextStyle(
                fontWeight: FontWeight.w200,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
            borderSide: const BorderSide(
              style: BorderStyle.none,
              color: Colors.black,
              width: .2,
            ),
          ),
          prefix: widget.prefix,
          suffix: widget.suffix ??
              (widget.canBeObsecured
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          obsecurePassword = !obsecurePassword;
                        });
                      },
                      child: Icon(
                        obsecurePassword
                            ? FontAwesomeIcons.eyeSlash
                            : Icons.remove_red_eye_sharp,
                        size: 20,
                      ),
                    )
                  : null),
        ),
        onChanged: (text) => widget.onChanged(text),
      ),
    );
  }
}
