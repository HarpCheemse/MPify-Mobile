import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';

class HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? hoverColor;
  final Color? hoverFontColor;
  final Color baseColor;
  final Widget? child;

  final Color splashColor;
  final Color highlightColor;

  final Widget Function(bool hovering)? childBuilder;

  const HoverButton({
    super.key,

    this.child,
    this.text = '',
    this.textStyle,
    this.hoverFontColor = Colors.transparent,
    this.hoverColor = const Color.fromARGB(255, 173, 173, 173),
    required this.baseColor,
    required this.borderRadius,
    required this.onPressed,
    this.width,
    this.height,
    this.childBuilder,

    this.splashColor = Colors.transparent,
    this.highlightColor = Colors.transparent,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        decoration:BoxDecoration(
          color: _hovering ? widget.hoverColor : widget.baseColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Material(
          color: _hovering ? widget.hoverColor : widget.baseColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            splashColor: widget.splashColor,
            highlightColor: widget.highlightColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onTap: widget.onPressed,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: widget.childBuilder != null
                  ? widget.childBuilder!(_hovering)
                  : widget.child ??
                        Text(
                          widget.text,
                          style:
                              widget.textStyle ??
                              montserratStyle(context: context, fontSize: 30),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
