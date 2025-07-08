import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/audio_ultis.dart';
import 'package:mpify/utils/string_ultis.dart';

import 'package:provider/provider.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/song_models.dart';

class PlaylistUltis {
  static Future<void> downloadMP3(BuildContext context, name, link) async {
    MiscUtils.showNotification('Attemping To Download $name');
    final String playlist = context.read<PlaylistModels>().selectedPlaylist;
    final Directory mp3Dir = await FolderUtils.checkMP3FolderExist();

    final String trimmedLink = link.split('&')[0];
    final String cleanName = name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final String identifier = StringUltis.hashYoutubeLink(link);
    try {
      final Process process = await Process.start(
        'yt-dlp',
        [
          '-x',
          '--audio-format',
          'mp3',
          '--no-continue',
          '-o',
          '$identifier.%(ext)s',
          trimmedLink,
        ],
        workingDirectory: mp3Dir.path,
        runInShell: true,
      );
      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        FolderUtils.writeLog('[stdout] $data');
      });
      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        FolderUtils.writeLog('[stderr] $data');
      });

      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        MiscUtils.showError('Error: Unable To Download $name');
        FolderUtils.writeLog('Error: Unable To Download $name');
        return;
      }
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Run yt-dlp.exe');
      MiscUtils.showError('Error: Unable To Run yt-dlp.exe');
    }
    if (await PlaylistUltis.writeSongToPlaylist(
      playlist,
      cleanName,
      trimmedLink,
      identifier,
    )) {
      MiscUtils.showSuccess('Download $name Successfully');
    } else {
      MiscUtils.showError('Error Writing $name To File. Proccess Canceled');
    }
  }

  static Future<bool> writeSongToPlaylist(
    String playlist,
    String name,
    String link,
    String identifier, {
    String artist = 'Unknown',
  }) async {
    final Directory targetDir = await FolderUtils.checkPlaylistFolderExist();
    final File playlistFile = File(p.join(targetDir.path, '$playlist.json'));

    if (!await playlistFile.exists()) {
      FolderUtils.writeLog(
        'Error: Unable To Write Song. $playlist.json Missing',
      );
      return false;
    }

    final Duration duration = await AudioUtils.getSongDuration(identifier);
    final int minutes = duration.inMinutes;
    final String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final formartedDuration = '$minutes:$seconds';
    final newSong = {
      'name': name,
      'duration': formartedDuration,
      'link': link,
      'artist': artist,
      'dateAdded': DateTime.now().toIso8601String(),
      'identifier': identifier,
    };
    try {
      final contents = await playlistFile.readAsString();
      List<dynamic> songs = [];
      if (contents.isNotEmpty) {
        songs = jsonDecode(contents);
      }
      songs.add(newSong);
      await playlistFile.writeAsString(jsonEncode(songs), mode: FileMode.write);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Write Song To $playlist.json');
      return false;
    }
    return true;
  }

  static Future<List<Song>> parsePlaylistJSON(File file) async {
    List<Song> parsedSongs = [];
    String contents;
    List<dynamic> songs;
    try {
      contents = await file.readAsString();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Error Reading $file');
      return parsedSongs;
    }
    if (contents.trim().isEmpty) {
      FolderUtils.writeLog('$file is empty');
      return parsedSongs;
    }

    try {
      songs = jsonDecode(contents);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Decode Json $file');
      return parsedSongs;
    }
    int errorCount = 0;
    for (var song in songs) {
      try {
        final String name = song['name'];
        final String duration = song['duration'];
        final String link = song['link'];
        final String artist = song['artist'];
        final DateTime dateAdded = DateTime.parse(song['dateAdded']);
        final String identifier = song['identifier'];
        parsedSongs.add(
          Song(
            name: name,
            identifier: identifier,
            duration: duration,
            link: link,
            artist: artist,
            dateAdded: dateAdded,
          ),
        );
      } catch (e) {
        errorCount++;
        FolderUtils.writeLog('Error: $e. Unable To Parse Song $song');
      }
    }
    if (errorCount > 0) {
      MiscUtils.showWarning(
        'Error: Unable To Parse $errorCount song(s). Check log.txt For More Details',
      );
    }
    return parsedSongs;
  }

  static Future<void> deletePlaylist(String playlist) async {
    final Directory playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final File playlistFile = File(p.join(playlistDir.path, '$playlist.json'));
    if (!await playlistFile.exists()) {
      FolderUtils.writeLog(
        'Error: Unable To Delete $playlistFile. $playlistFile Does Not Exist',
      );
      MiscUtils.showError('Error: $playlist Does Not Exisit');
      return;
    }
    try {
      await playlistFile.delete();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Delete $playlistFile');
      MiscUtils.showError('Error: Unable To Delete $playlist');
    }
    MiscUtils.showSuccess('Successfully Deleted Playlist From Device');
  }

  static Future<void> deleteSongFromPlaylist(
    String identifier,
    String selectedPlaylist,
    BuildContext context,
  ) async {
    final songModels = context.read<SongModels>();
    final Directory playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final File playlistFile = File(
      p.join(playlistDir.path, '$selectedPlaylist.json'),
    );
    if (!await playlistFile.exists()) {
      FolderUtils.writeLog(
        'Error: Unable To Delete $playlistFile. $playlistFile Does Not Exist',
      );
      MiscUtils.showError('Error: $selectedPlaylist Does Not Exisit');
      return;
    }
    try {
      final String contents = await playlistFile.readAsString();
      List<dynamic> songs = contents.isNotEmpty ? jsonDecode(contents) : [];
      final List<dynamic> updatedList = songs.where((song) {
        return song['identifier'] != identifier;
      }).toList();
      await playlistFile.writeAsString(
        jsonEncode(updatedList),
        mode: FileMode.write,
      );
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Delete $playlistFile');
      MiscUtils.showError('Error: Unable To Delete Song');
      return;
    }
    MiscUtils.showSuccess('Successfully Delete Song From Playlist');
    songModels.loadSong(selectedPlaylist);
    debugPrint(selectedPlaylist);
  }

  static Future<void> deleteSongFromDevice(String identifier, BuildContext context) async {
    int errorCount = 0;
    final selectedPlaylist = context.read<PlaylistModels>().selectedPlaylist;
    final songModels = context.read<SongModels>();
    final Directory playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final List<dynamic> playlists = playlistDir
        .listSync()
        .where((file) => file.path.endsWith('.json'))
        .toList();
    for (final playlist in playlists) {
      try {
        //delete song from playlist.json
        final File file = File(playlist.path);
        final String contents = await file.readAsString();
        List<dynamic> songs = contents.isNotEmpty ? jsonDecode(contents) : [];
        final updatedList = songs.where((song) {
          return song['identifier'] != identifier;
        }).toList();
        await file.writeAsString(jsonEncode(updatedList), mode: FileMode.write);
      } catch (e) {
        FolderUtils.writeLog(
          'Error: $e. Unable To Delete Song Metadata From Device',
        );
        errorCount++;
      }
    }
    //delete song.mp3 from mp3 folder
    final Directory mp3Dir = await FolderUtils.checkMP3FolderExist();
    final File mp3File = File(p.join(mp3Dir.path, '$identifier.mp3'));
    try {
      if (await mp3File.exists()) {
        await mp3File.delete();
      }
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Delete Song MP3 From Device');
      errorCount++;
    }
    //delete song cover from cover fodler
    final Directory coverDir = await FolderUtils.checkCoverFolderExist();
    final File coverFile = File(p.join(coverDir.path, '$identifier.png'));
    try {
      if (await coverFile.exists()) {
        await coverFile.delete();
      }
    } catch (e) {
      FolderUtils.writeLog(
        'Error: $e. Unable To Delete Song Cover From Device',
      );
      errorCount++;
    }
    //delete song lyric
    final Directory lyricDir = await FolderUtils.checkLyricFolderExist();
    final File lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
    try {
      if (await lyricFile.exists()) {
        await lyricFile.delete();
      }
    } catch (e) {
      FolderUtils.writeLog(
        'Error: $e. Unable To Delete Song Lyric From Device',
      );
      errorCount++;
    }
    switch (errorCount) {
      case 0:
        MiscUtils.showSuccess('Successfully Deleted Song From Device');
        break;
      case 1:
        MiscUtils.showWarning(
          'Warning: Unable To Delete Some Part Of Song From Device',
        );
        break;
      default:
        MiscUtils.showError('Error: Unable To Delete Song From Device');
    }
    songModels.loadSong(selectedPlaylist);
  }
}
