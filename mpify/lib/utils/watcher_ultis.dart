import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mpify/models/song_models.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/models/playlist_models.dart';

class Watcher {
  static Timer? _debounce;
  static StreamSubscription<FileSystemEvent>? _sub;

  static void playlistSongWatcher(BuildContext context, String playlist) {
    _sub?.cancel();
    _debounce?.cancel();

    final songModels = context.read<SongModels>();
    final playlistFile = File(
      p.join(Directory.current.path, '..', 'playlist', '$playlist.json'),
    );

    if (!playlistFile.existsSync()) {
      debugPrint('playlist does not exist');
      return;
    }

    _sub = playlistFile.watch(events: FileSystemEvent.modify).listen((event) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (!context.mounted) return;
        songModels
            .loadSong(playlist)
            .catchError((e) => debugPrint('Failed to load playlist: $e'));
      });
    });
  }

  static Future<void> playlistWatcher(BuildContext context) async {
    final playlistModels = context.read<PlaylistModels>();
    final target = await FolderUtils.checkPlaylistFolderExist();
    List<String> listOfPlaylist = playlistModels.playlists;

    //get all .json when init
    listOfPlaylist = await target
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .map((entity) => entity.uri.pathSegments.last.replaceAll('.json', ''))
        .toList();
    playlistModels.updateListOfPlaylist(listOfPlaylist);

    //update .json
    target.watch().listen((event) async {
      if (event.path.endsWith('json')) {
        listOfPlaylist = await target
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.json'))
            .map(
              (entity) => entity.uri.pathSegments.last.replaceAll('.json', ''),
            )
            .toList();
        playlistModels.updateListOfPlaylist(listOfPlaylist);
      }
    });
  }
}
