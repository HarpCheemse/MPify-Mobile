import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpify/models/audio_models.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/settings_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/screen/home_screen.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
late final Directory globalAppDocDir;

double maxScreenWidth = 1920;
double maxScreenHeight = 1080;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  globalAppDocDir = await getApplicationDocumentsDirectory();

  runZonedGuarded(
    () async {
      await FolderUtils.clearLog();

      try {
        runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PlaylistModels()),
              ChangeNotifierProvider(create: (_) => SongModels()),
              ChangeNotifierProvider(
                create: (context) {
                  final songModels = Provider.of<SongModels>(
                    context,
                    listen: false,
                  );
                  return AudioModels(songModels: songModels);
                },
              ),
              ChangeNotifierProvider(
                create: (context) {
                  final settingsModel = SettingsModels();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    settingsModel.loadAllPrefs(context);
                  });
                  return settingsModel;
                },
              ),
            ],
            child: MPify(),
          ),
        );
      } catch (e, stack) {
        debugPrint('error: $e');
        debugPrint('$stack');
      }
    },
    (e, stack) {
      debugPrint('error: $e');
      debugPrint('$stack');
    },
  );
}

class MPify extends StatelessWidget {
  const MPify({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<SettingsModels>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          surface: Colors.white,
          primary: Colors.lightBlueAccent,
          onSurface: Colors.black,
          surfaceContainer: const Color.fromARGB(255, 221, 221, 221),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          surface: Colors.black,
          primary: Colors.teal,
          onSurface: Colors.white,
          surfaceContainer: const Color.fromARGB(255, 24, 24, 24),
        ),
      ),
      themeMode: themeProvider.themeMode,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: HomeScreen(key: homeScreenKey),
    );
  }
}
