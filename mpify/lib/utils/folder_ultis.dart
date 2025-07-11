import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

class FolderUtils {
  static Future<void> createPlaylistFolder(folderName) async {
    if (folderName == 'Playlist Name') {
      MiscUtils.showWarning(
        'Warning: Cannot Create A Playlist With The Name "Playlist Name"',
      );
      return;
    }
    final playlistDir = await checkPlaylistFolderExist();
    final String filePath = p.join(playlistDir.path, '$folderName.json');
    final File playlistFile = File(filePath);
    if (!await playlistFile.exists()) {
      playlistFile.create(recursive: true);
      MiscUtils.showSuccess('Successfully Created Playlist: $folderName');
      return;
    }
    MiscUtils.showError('Playlist $folderName Already Existed');
  }

  static Future<Directory> checkPlaylistFolderExist() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory playlistDir = Directory(p.join(appDocDir.path, 'playlist'));
    if (!await playlistDir.exists()) {
      await playlistDir.create(recursive: true);
    }
    return playlistDir;
  }

  static Future<Directory> checkMP3FolderExist() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory mp3Dir = Directory(p.join(appDocDir.path, 'mp3'));
    if (!await mp3Dir.exists()) {
      await mp3Dir.create(recursive: true);
    }
    return mp3Dir;
  }

  static Future<Directory> checkCoverFolderExist() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory coverDir = Directory(p.join(appDocDir.path, 'cover'));
    if (!await coverDir.exists()) {
      await coverDir.create(recursive: true);
    }
    return coverDir;
  }

  static Future<Directory> checkLyricFolderExist() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory lyricDir = Directory(p.join(appDocDir.path, 'lyric'));
    if (!await lyricDir.exists()) {
      await lyricDir.create(recursive: true);
    }
    return lyricDir;
  }

  static Future<Directory> checkBackupFolderExist() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory backupDir = Directory(p.join(appDocDir.path, 'backup'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  static void openFolderInExplorer() async {
    final Directory path = await FolderUtils.checkPlaylistFolderExist();
    MiscUtils.showNotification('Go To $path');
  }

  static void writeLyricToFolder(text, identifier) async {
    final Directory lyricDir = await checkLyricFolderExist();
    final File lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
    if (!await lyricFile.exists()) {
      lyricFile.create(recursive: true);
    }
    await lyricFile.writeAsString(text);
  }

  static Future<String?> getSongLyric(String identifier) async {
    final Directory lyricDir = await checkLyricFolderExist();
    final File lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
    if (!await lyricFile.exists()) return null;
    final String lyric = await lyricFile.readAsString();
    return lyric;
  }

  static Future<bool> createBackupFile(String playlist) async {
    final DateTime timeStamp = DateTime.now();
    Directory backupDir = Directory('/storage/emulated/0/Download');
    if (!await backupDir.exists()) {
      return false;
    }
    final Directory playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final String backupName =
        '${timeStamp.year}_${timeStamp.month}_${timeStamp.day}_${timeStamp.hour}_${timeStamp.minute}_${timeStamp.second}_backup';
    final Directory backupFolder = Directory(
      p.join(backupDir.path, backupName),
    );
    await backupFolder.create(recursive: true);
    final File playlistJson = File(p.join(playlistDir.path, '$playlist.json'));
    if (!await playlistJson.exists()) {
      return false;
    }

    //copy metaData

    List<dynamic> songs = [];
    late final String contents;
    try {
      contents = await playlistJson.readAsString();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Read $playlistJson');
      return false;
    }
    if (contents.isNotEmpty) {
      songs = jsonDecode(contents);
    }
    await File(
      p.join(backupFolder.path, 'metadata.json'),
    ).writeAsString(jsonEncode(songs), mode: FileMode.write);

    //copy cover

    final Directory backupCoverDir = Directory(
      p.join(backupFolder.path, 'cover'),
    );
    await backupCoverDir.create(recursive: true);
    final Directory coverDir = await checkCoverFolderExist();
    try {
      for (int i = 0; i < songs.length; i++) {
        final String identifier = songs[i]['identifier'];
        final File coverFile = File(p.join(coverDir.path, '$identifier.png'));
        if (!await coverFile.exists()) continue;
        await File(
          coverFile.path,
        ).copy(p.join(backupCoverDir.path, '$identifier.png'));
      }
    } catch (e) {
      MiscUtils.showError('Error: Unable To Create Backup Cover');
      FolderUtils.writeLog('Error: $e. Unable To Create Backup Cover');
      return false;
    }
    //copy lyric
    try {
      final Directory backupLyricDir = Directory(
        p.join(backupFolder.path, 'lyric'),
      );
      await backupLyricDir.create(recursive: true);
      final Directory lyricDir = await checkLyricFolderExist();
      for (int i = 0; i < songs.length; i++) {
        final String identifier = songs[i]['identifier'];
        final File lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
        if (!await lyricFile.exists()) continue;
        await File(
          lyricFile.path,
        ).copy(p.join(backupLyricDir.path, '$identifier.txt'));
      }
    } catch (e) {
      MiscUtils.showError('Error: Unable To Create Backup Lyric');
      FolderUtils.writeLog('Error: $e. Unable To Create Backup Lyric');
      return false;
    }
    //copy mp3
    try {
      final Directory backupMP3Dir = Directory(
        p.join(backupFolder.path, 'mp3'),
      );
      await backupMP3Dir.create(recursive: true);
      final Directory mp3Dir = await checkMP3FolderExist();
      for (int i = 0; i < songs.length; i++) {
        final String identifier = songs[i]['identifier'];
        final File mp3File = File(p.join(mp3Dir.path, '$identifier.mp3'));
        if (!await mp3File.exists()) continue;
        await File(
          mp3File.path,
        ).copy(p.join(backupMP3Dir.path, '$identifier.mp3'));
      }
    } catch (e) {
      MiscUtils.showError('Error: Unable To Create Backup MP3');
      FolderUtils.writeLog('Error: $e. Unable To Create Backup MP3');
      return false;
    }
    //zip file
    await Future.delayed(Duration(milliseconds: 500));
    try {
      // ignore: prefer_interpolation_to_compose_strings
      final String zipPath = backupFolder.path + '.zip';
      final File zipFile = File(zipPath);
      await zipFolder(backupFolder, zipFile);
    } catch (e) {
      MiscUtils.showError('Error: Unable To Zip Folder');
      FolderUtils.writeLog('Error: $e. Unable To Zip Folder');
      return false;
    }
    //delete the Dir
    try {
      await backupFolder.delete(recursive: true);
    } catch (e) {
      MiscUtils.showError('Error: Unable To Delete Temp BackupFolder');
      FolderUtils.writeLog('Error: $e. Unable To Delete Temp Backup Cover');
      return false;
    }
    return true;
  }

  static Future<void> zipFolder(Directory inputDir, File outputFile) async {
    final ZipFileEncoder zipEncoder = ZipFileEncoder();
    zipEncoder.create(outputFile.path);
    await zipEncoder.addDirectory(inputDir);
    zipEncoder.close();
  }

  static Future<void> importBackupFile(
    String playlistName,
    FilePickerResult result,
  ) async {
    MiscUtils.showNotification('Attempting To Import Backup File');
    int errorCount = 0;
    final Directory playlisrDir = await checkPlaylistFolderExist();
    final Directory coverDir = await checkCoverFolderExist();
    final Directory lyricDir = await checkLyricFolderExist();
    final Directory mp3Dir = await checkMP3FolderExist();
    final filePath = result.files.first.path;
    if(filePath == null) {
      MiscUtils.showError('No File Path Found');
      return;
    }
    final inputStream = InputFileStream(filePath);
    final archive = ZipDecoder().decodeStream(inputStream);


    for (final file in archive) {
      if (file.isFile) {
        final filename = file.name;
        //copy metadata.json
        if (filename.endsWith('/metadata.json')) {
          try {
            final jsonString = utf8.decode(file.content as List<int>);
            final List<dynamic> metadata = jsonDecode(jsonString);
            if (metadata.isEmpty) {
              return;
            }
            final List<Song> songs = [];
            for (var song in metadata) {
              final String name = song['name'];
              final String duration = song['duration'];
              final String link = song['link'];
              final String artist = song['artist'];
              final DateTime dateAdded = DateTime.parse(song['dateAdded']);
              final String identifier = song['identifier'];
              songs.add(
                Song(
                  name: name,
                  link: link,
                  duration: duration,
                  artist: artist,
                  dateAdded: dateAdded,
                  identifier: identifier,
                ),
              );
            }
            final File playlistFile = File(
              p.join(playlisrDir.path, '$playlistName.json'),
            );
            await playlistFile.writeAsString(
              jsonEncode(
                songs
                    .map(
                      (s) => {
                        'name': s.name,
                        'link': s.link,
                        'artist': s.artist,
                        'duration': s.duration,
                        'dateAdded': s.dateAdded.toIso8601String(),
                        'identifier': s.identifier,
                      },
                    )
                    .toList(),
              ),
              mode: FileMode.write,
            );
          } catch (e) {
            MiscUtils.showError('Error: Unable To Import Metadata');
            FolderUtils.writeLog('Error: $e. Unable To Import Metadata');
            return;
          }
        }
        //copy image
        else if (filename.endsWith('.png')) {
          try {
            final String filename = p.basename(file.name);
            final File coverFile = File(p.join(coverDir.path, filename));
            await coverFile.create(recursive: true);
            await coverFile.writeAsBytes(file.content as List<int>);
          } catch (e) {
            FolderUtils.writeLog('Error: $e. Unable To Import Png');
            errorCount++;
          }
        }
        //copy lyric
        else if (filename.endsWith('.txt')) {
          try {
            final String filename = p.basename(file.name);
            final File lyricFile = File(p.join(lyricDir.path, filename));
            await lyricFile.create(recursive: true);
            await lyricFile.writeAsBytes(file.content as List<int>);
          } catch (e) {
            FolderUtils.writeLog('Error: $e. Unable To Import Lyric');
            errorCount++;
          }
        }
        //copy mp3
        else if (filename.endsWith('.mp3')) {
          try {
            final String filename = p.basename(file.name);
            final File mp3File = File(p.join(mp3Dir.path, filename));
            await mp3File.create(recursive: true);
            await mp3File.writeAsBytes(file.content as List<int>);
          } catch (e) {
            FolderUtils.writeLog('Error: $e. Unable To Import MP3');
            errorCount++;
          }
        }
      }
    }
    if (errorCount > 0) {
      MiscUtils.showWarning(
        'Warning: Imported Back Up File With $errorCount Error(s)',
      );
    } else {
      MiscUtils.showSuccess('Successfully Imported Backup File');
    }
  }

  static Future<void> writeLog(String messege) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final logFile = File(p.join(appDocDir.path, 'log.txt'));
    if (!await logFile.exists()) {
      await logFile.create(recursive: true);
    }
    try {
      await logFile.writeAsString('$messege\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Error: $e. Unable to write log');
    }
  }

  static Future<void> clearLog() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File logFile = File(p.join(appDocDir.path, 'log.txt'));
    try {
      await logFile.writeAsString('', mode: FileMode.write);
    } catch (e) {
      MiscUtils.showWarning('Warning: Unable To Clear Log.txt');
    }
  }

  static Future<bool> addCustomMP3(String selectedPlaylist) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      MiscUtils.showError('Error: No MP3 File Choosen');
      return false;
    }
    final PlatformFile mp3File = result.files.first;
    if (mp3File.extension != "mp3") {
      MiscUtils.showError("Error: Please Pick A MP3 File");
      return false;
    }
    Uint8List? fileBytes = mp3File.bytes;
    if (fileBytes == null) {
      MiscUtils.showError('Error: Unable To Read File');
      FolderUtils.writeLog('Error Unable To Read File');
      return false;
    }

    final String identifier = sha256.convert(fileBytes).toString();

    final Directory mp3Dir = await checkMP3FolderExist();
    final File savedMp3 = File(p.join(mp3Dir.path, '$identifier.mp3'));
    await savedMp3.writeAsBytes(fileBytes);

    final String name = mp3File.name;
    final String link = "";
    final String duration = "";
    final String artist = 'Unknown';
    final DateTime dateAdded = DateTime.now();

    final Directory playlisrDir = await checkPlaylistFolderExist();
    final File playlistFile = File(
      p.join(playlisrDir.path, '$selectedPlaylist.json'),
    );
    if (!await playlistFile.exists()) {
      await playlistFile.create(recursive: true);
    }
    try {
      String content = await playlistFile.readAsString();
      List<Song> playlist = [];
      if (content.isNotEmpty) {
        final List<dynamic> raw = jsonDecode(content);
        playlist = raw.map((song) => Song.fromJson(song)).toList();
      }
      final Song newMp3 = Song(
        name: name,
        link: link,
        duration: duration,
        artist: artist,
        dateAdded: dateAdded,
        identifier: identifier,
      );
      playlist.add(newMp3);

      await playlistFile.writeAsString(
        jsonEncode(playlist.map((song) => song.toJson()).toList()),
      );
    } catch (e) {
      MiscUtils.showError(
        "Error: Unabled To Write To Playlist: $selectedPlaylist",
      );
      writeLog("Error: $e. Unable To Write In Playlist: $selectedPlaylist");
      return false;
    }
    MiscUtils.showSuccess('Successfully Added Custom MP3');
    return true;
  }
}
