import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/screen/home_screen.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModels extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toogleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isDarkmode', isDark);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Saved Dark Mode Prefs');
    }

    notifyListeners();
  }

  Future<void> loadAllPrefs(BuildContext context) async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable to Load Prefs');
      return;
    }
    final selectedPlaylist =
        prefs.getString('selectedPlaylist') ?? 'Playlist Name';
    if (!context.mounted) return;
    context.read<PlaylistModels>().setSelectedPlaylist(selectedPlaylist);
    if (selectedPlaylist != "Playlist Name") {
      homeScreenKey.currentState?.navigateToPage(1);
    }
    final isDark = prefs.getBool('isDarkmode') ?? true;
    toogleTheme(isDark);

    final isShuffle = prefs.getBool('isShuffle') ?? true;
    context.read<SongModels>().setIsShuffe(isShuffle);

    final sortOptioStr = prefs.getString('sortOption');
    final sortOption = SortOption.values.firstWhere(
      (e) => e.name == sortOptioStr,
      orElse: () => SortOption.newest,
    );

    final activeSongJson = prefs.getString('activeSong');
    if (activeSongJson != null) {
      final List<dynamic> songs = jsonDecode(activeSongJson);
      final activeSong = songs.map((song) => Song.fromJson(song)).toList();
      //wait for ui to build first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SongModels>().setSongsActive(activeSong);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongModels>().applySortActivePlaylist(sortOption);
    });
  }

  bool _showArtist = true;
  bool get showArtist => _showArtist;
  void setShowArtist(bool value) {
    _showArtist = value;
    notifyListeners();
  }

  bool _showDuration = true;
  bool get showDuration => _showDuration;
  void setShowDuration(bool value) {
    _showDuration = value;
    notifyListeners();
  }
}
