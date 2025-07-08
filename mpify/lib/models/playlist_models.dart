import 'package:flutter/material.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistModels extends ChangeNotifier{
  String _selectedPlaylist = 'Playlist Name';
  bool _isPlayerOpen = true;

  String _playingPlaylist = '';
  String get playingPlaylist => _playingPlaylist;
  void setPlayingPlaylist() {
    _playingPlaylist = _selectedPlaylist;
    notifyListeners();
  }
  
  String get selectedPlaylist => _selectedPlaylist;
  List<String> _playlists = [];
  List<String> get playlists => _playlists;
  bool get isPlayerOpen => _isPlayerOpen;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  

  void updateSongSearchQuery(query) async {
    _searchQuery = query;
    notifyListeners();
  }

  void tooglePlayer() {
    _isPlayerOpen = !_isPlayerOpen;
    notifyListeners();
  }


  void updateListOfPlaylist(List<String> newListOfPlaylist) {
    _playlists = newListOfPlaylist;
    notifyListeners();
  }


  void setSelectedPlaylist(String name) async{
    _selectedPlaylist = name;
    try {
      final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedPlaylist', name);
    }
    catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Save Selected Playlist Pref');
    }
    notifyListeners();
  }
  
}