import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mpify/models/audio_models.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:path/path.dart' as p;

import 'package:audioplayers/audioplayers.dart';

import 'package:mpify/utils/folder_ultis.dart';
import 'package:provider/provider.dart';

class AudioUtils {
  static final AudioPlayer player = AudioPlayer();

  static Future<Duration> getSongDuration(String identifier) async {
    final Directory mp3Dir = await FolderUtils.checkMP3FolderExist();
    final String mp3FilePath = p.join(mp3Dir.path, '$identifier.mp3');
    final File mp3File = File(mp3FilePath);
    final String ffprobeExecutablePath = p.join(
      Directory.current.path,
      '..',
      'ffprobe.exe',
    );
    if (!await mp3File.exists()) {
      MiscUtils.showError('Error: Unable To Get Song Duration');
      FolderUtils.writeLog('Error: Unable To Get Song Duration');
      return Duration.zero;
    }
    late final Process process;
    try {
      process = await Process.start(ffprobeExecutablePath, [
        '-i',
        mp3FilePath,
        '-v',
        'quiet',
        '-show_entries',
        'format=duration',
        '-hide_banner',
        '-of',
        'default=noprint_wrappers=1:nokey=1',
      ], runInShell: false);
    } catch (e) {
      FolderUtils.writeLog('Error: Unable Run FFProbe');
      return Duration.zero;
    }

    final List<String> stdoutLines = [];
    final List<String> stderrLines = [];

    process.stdout.transform(systemEncoding.decoder).listen((String data) {
      stdoutLines.add(data.trim());
    });
    process.stderr.transform(systemEncoding.decoder).listen((String data) {
      stderrLines.add(data.trim());
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      FolderUtils.writeLog('Full STDERR: ${stderrLines.join('\n')}');
      return Duration.zero;
    }

    final rawOutput = stdoutLines.join('').trim();
    final seconds = double.tryParse(rawOutput);

    if (seconds == null) {
      FolderUtils.writeLog(
        'Error: Unable To Parse Duration From: "$rawOutput"',
      );
      return Duration.zero;
    }
    return Duration(microseconds: (seconds * 1000000).toInt());
  }

  static Future<void> playSong(identifier) async {
    final Directory target = await FolderUtils.checkMP3FolderExist();
    final File songFile = File(p.join(target.path, '$identifier.mp3'));
    if (!await songFile.exists()) {
      FolderUtils.writeLog('Error: Unable To Play Song. MP3 File Missing');
      MiscUtils.showError('Error: Unable To Play Song. MP3 File Missing');
      return;
    }
    try {
      player.stop();
      await player.play(DeviceFileSource(songFile.path));
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
      await player.resume();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Resume Song');
      MiscUtils.showError('Error: Unable To Resume Song');
    }
  }

  static Future<void> skipForward(BuildContext context) async {
    if (context.read<AudioModels>().songDuration.inSeconds <= 0) return;
    try {
      final position = await player.getCurrentPosition();
      if (position != null) {
        await player.seek(position + const Duration(seconds: 5));
      }
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Skip Forward');
      MiscUtils.showError('Error: Unable To Skip Forward');
    }
  }

  static Future<void> skipBackward(BuildContext context) async {
    if (context.read<AudioModels>().songDuration.inSeconds <= 0) return;
    try {
      final position = await player.getCurrentPosition();
      if (position != null) {
        final newPosition = position - const Duration(seconds: 5);
        await player.seek(
          newPosition > Duration.zero ? newPosition : Duration.zero,
        );
      }
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Skip Backward');
      MiscUtils.showError('Error: Unable To Skip Backward');
    }
  }

  static Future<void> setVolume(double value) async {
    try {
      await player.setVolume(value);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Set Volume To $value');
      MiscUtils.showError('Error: Unable To Set Volume');
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
