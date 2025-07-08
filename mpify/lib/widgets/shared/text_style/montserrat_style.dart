import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

TextStyle montserratStyle({
  required BuildContext context,
  Color? color,
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w700,
}) {
  return GoogleFonts.montserrat(
    color: color ?? Theme.of(context).colorScheme.onSurface,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}