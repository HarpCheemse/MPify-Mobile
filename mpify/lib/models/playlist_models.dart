import 'package:flutter/material.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistModels extends ChangeNotifier {
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void updatePlaylistSearchQuery(query) {
    _searchQuery = query;
    notifyListeners();
  }

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
  List<String> get playlists {
    if (_searchQuery.isEmpty) return _playlists;
    final String q = _searchQuery.toLowerCase();
    return _playlists.where((playlist) => playlist.toLowerCase().contains(q)).toList();
  }

  bool get isPlayerOpen => _isPlayerOpen;

  void tooglePlayer() {
    _isPlayerOpen = !_isPlayerOpen;
    notifyListeners();
  }

  void updateListOfPlaylist(List<String> newListOfPlaylist) {
    _playlists = newListOfPlaylist;
    notifyListeners();
  }

  void setSelectedPlaylist(String name) async {
    _selectedPlaylist = name;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('selectedPlaylist', name);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Save Selected Playlist Pref');
    }
    notifyListeners();
  }
}
