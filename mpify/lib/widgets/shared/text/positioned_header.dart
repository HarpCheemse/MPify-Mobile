import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';

Widget positionedHeader(
  BuildContext context,
  double top,
  double left,
  String text,
  double fontSize,
  double fontWeight,
  Color? color,
) {
  final fontWeightMap = {
    100: FontWeight.w100,
    200: FontWeight.w200,
    300: FontWeight.w300,
    400: FontWeight.w400,
    500: FontWeight.w500,
    600: FontWeight.w600,
    700: FontWeight.w700,
    800: FontWeight.w800,
    900: FontWeight.w900,
  };

  return Positioned(
    top: top,
    left: left,
    child: Text(
      text,
      style: montserratStyle(
        context: context,
        fontSize: fontSize,
        fontWeight: fontWeightMap[fontWeight] ?? FontWeight.normal,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
}
