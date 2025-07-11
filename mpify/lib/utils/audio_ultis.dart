import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mpify/main.dart';
import 'package:mpify/models/audio_models.dart';
import 'package:mpify/utils/audio_handler.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:path/path.dart' as p;

import 'package:mpify/utils/folder_ultis.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class AudioUtils {

  static final AudioPlayer player = AudioPlayer();
  static Future<Uri> getCoverUri(String identifier) async {
  final coverDir = await FolderUtils.checkCoverFolderExist();
  final coverFile = File(p.join(coverDir.path, '$identifier.png'));

  if (await coverFile.exists()) {
    return Uri.file(coverFile.path);
  } else {
    final bytes = await rootBundle.load('assets/placeholder.png');
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'placeholder_$identifier.png'));
    await tempFile.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    return Uri.file(tempFile.path);
  }
}

  static Future<void> playSong(
    String identifier,
    String name,
    String artist,
  ) async {
    final Directory target = await FolderUtils.checkMP3FolderExist();
    final File songFile = File(p.join(target.path, '$identifier.mp3'));
    if (!await songFile.exists()) {
      FolderUtils.writeLog('Error: Unable To Play Song. MP3 File Missing');
      MiscUtils.showError('Error: Unable To Play Song. MP3 File Missing');
      return;
    }
    try {
      final Uri coverSrc = await getCoverUri(identifier);
      final mediaItem = MediaItem(
        id: identifier,
        title: name,
        artist: artist,
        artUri: coverSrc,
        album: 'Local',
      );
      await (audioHandler as MyAudioHandler).updateMediaItem(mediaItem);
      final audioSource = AudioSource.file(songFile.path, tag: mediaItem);
      await player.stop();
      await player.setAudioSource(audioSource);
      await audioHandler.play();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Play Song');
      MiscUtils.showError('Error: Unable To Play Song');
    }
  }

  static Future<void> pauseSong() async {
    try {
      await player.pause();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Pause Song');
      MiscUtils.showError('Error: Unable To Pause Song');
    }
  }

  static Future<void> resumeSong() async {
    try {
      await player.play();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Resume Song');
      MiscUtils.showError('Error: Unable To Resume Song');
    }
  }

  static Future<void> skipForward(BuildContext context) async {
    if (context.read<AudioModels>().songDuration.inSeconds <= 0) return;
    try {
      final position = player.position;
      await player.seek(position + const Duration(seconds: 5));
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Skip Forward');
      MiscUtils.showError('Error: Unable To Skip Forward');
    }
  }

  static Future<void> skipBackward(BuildContext context) async {
    if (context.read<AudioModels>().songDuration.inSeconds <= 0) return;
    try {
      final position = player.position;
      final newPosition = position - const Duration(seconds: 5);
      await player.seek(
        newPosition > Duration.zero ? newPosition : Duration.zero,
      );
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Skip Backward');
      MiscUtils.showError('Error: Unable To Skip Backward');
    }
  }

  static Future<void> stopSong() async {
    try {
      await player.stop();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Stop Song');
      MiscUtils.showError('Error: Unable To Stop Song');
    }
  }
}
