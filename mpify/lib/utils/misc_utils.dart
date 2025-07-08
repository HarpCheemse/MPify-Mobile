import 'package:flutter/material.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/main.dart';
import 'package:screen_retriever/screen_retriever.dart';

import 'package:top_snackbar_flutter/top_snack_bar.dart';

class MiscUtils {
  static void showNotification(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = navigatorKey.currentState?.overlay;
      if (overlay == null) {
        FolderUtils.writeLog(
          'Error: Navigator Overlay Is Null. Unable To Show Notification',
        );
        return;
      }
      showTopSnackBar(
        overlay,
        Material(
          color: Colors.transparent,
          child: Align(
            child: Container(
              width: 800,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(navigatorKey.currentContext!).colorScheme.surfaceContainer,
              ),
              child: Center(
                child: Text(
                  message,
                  style: montserratStyle(context: navigatorKey.currentContext!),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  static void showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = navigatorKey.currentState?.overlay;
      if (overlay == null) {
        FolderUtils.writeLog(
          'Error: Main App Context Is Null. Unable To Show Notification',
        );
        return;
      }
      showTopSnackBar(
        overlay,
        Material(
          color: Colors.transparent,
          child: Align(
            child: Container(
              width: 800,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(164, 177, 41, 41),
              ),
              child: Center(
                child: Text(message, style: montserratStyle(context: navigatorKey.currentContext!)),
              ),
            ),
          ),
        ),
      );
    });
  }

  static void showSuccess(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = navigatorKey.currentState?.overlay;
      if (overlay == null) {
        FolderUtils.writeLog(
          'Error: Navigator Overlay Is Null. Unable To Show Notification',
        );
        return;
      }
      showTopSnackBar(
        overlay,
        Material(
          color: Colors.transparent,
          child: Align(
            child: Container(
              width: 800,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(166, 2, 132, 12),
              ),
              child: Center(
                child: Text(message, style: montserratStyle(context: navigatorKey.currentContext!)),
              ),
            ),
          ),
        ),
      );
    });
  }

  static void showWarning(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = navigatorKey.currentState?.overlay;
      if (overlay == null) {
        FolderUtils.writeLog(
          'Error: Navigator Overlay Is Null. Unable To Show Notification',
        );
        return;
      }
      showTopSnackBar(
        overlay,
        Material(
          color: Colors.transparent,
          child: Align(
            child: Container(
              width: 800,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(218, 150, 138, 0),
              ),
              child: Center(
                child: Text(message, style: montserratStyle(context: navigatorKey.currentContext!)),
              ),
            ),
          ),
        ),
      );
    });
  }
 static Future<double> getPhysicalScreenWidth() async {
  try {
    final screen = await screenRetriever.getPrimaryDisplay();
    return screen.size.width;
  }
  catch (e) {
    FolderUtils.writeLog('Error: $e. Unable To Get Screen Width. Default To 1920');
    return 1920;
  }
  
}
static Future<double> getPhysicalScreenHeight() async {
  try {
    final screen = await screenRetriever.getPrimaryDisplay();
    return screen.size.height;
  }
  catch (e) {
    FolderUtils.writeLog('Error: $e. Unable To Get Screen Height. Default To 1080');
    return 1080;
  }
}
}
