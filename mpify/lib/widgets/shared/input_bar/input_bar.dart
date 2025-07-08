import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';

class CustomInputBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String hintText;
  final Color searchColor;
  final Color fontColor;
  final Color hintColor;
  final Color iconColor;
  final IconData icon;
  final double? fontSize;

  const CustomInputBar({
    super.key,
    required this.controller,
    required this.hintColor,
    required this.onChanged,
    required this.hintText,
    required this.searchColor,
    required this.fontColor,
    required this.iconColor,
    required this.icon,
    this.fontSize
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: montserratStyle(context: context, color: fontColor),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: montserratStyle(
          context: context,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
          fontSize: fontSize ?? 16
        ),
        prefixIcon: Icon(icon, color: iconColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: searchColor,
      ),
      onChanged: onChanged,
    );
  }
}
