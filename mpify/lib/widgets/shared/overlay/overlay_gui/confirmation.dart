import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';

class Confirmation extends StatefulWidget {
  final String headerText;
  final String warningText;
  final String? playlist;
  final Future<void> Function() function;
  const Confirmation({
    super.key,
    required this.headerText,
    required this.warningText,
    required this.function,
    this.playlist,
  });

  @override
  State<Confirmation> createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: const Color.fromARGB(255, 43, 43, 43),
      child: Container(
        width: 300,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Column(
          children: [
            SizedBox(height: 30),
            Center(child: Text(widget.headerText, style: montserratStyle(context: context))),
            SizedBox(height: 40),
            SizedBox(
              width: 280,
              child: Text(
                widget.warningText,
                style: montserratStyle(context: context,color: Colors.redAccent),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HoverButton(
                    baseColor: Colors.transparent,
                    borderRadius: 0,
                    onPressed: () {
                      OverlayController.hideOverlay();
                    },
                    width: 80,
                    hoverColor: Colors.transparent,
                    height: 40,
                    child: Transform.translate(
                      offset: Offset(10, 10),
                      child: Text('Cancel', style: montserratStyle(context: context)),
                    ),
                  ),
                  SizedBox(width: 30),
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: 0,
                    onPressed: () async {
                      await widget.function();
                      OverlayController.hideOverlay();
                    },
                    width: 80,
                    height: 40,
                    child: Transform.translate(
                      offset: Offset(10, 10),
                      child: Text('Confirm', style: montserratStyle(context: context)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
