import 'package:flutter/material.dart';

class OverlayController {
  static OverlayEntry? _entry;

  static void show(BuildContext context, Widget child) {
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: OverlayController.hideOverlay,
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
          Center(
            child: GestureDetector(onTap: () {}, child: child),
          ),
        ],
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  static void hideOverlay() {
    _entry?.remove();
    _entry = null;
  }
}