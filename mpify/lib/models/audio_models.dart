import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/audio_ultis.dart';
import 'package:mpify/utils/misc_utils.dart';

class AudioModels extends ChangeNotifier {
  final SongModels songModels;
  final _audioPlayer = AudioUtils.player;
  Duration _songDuration = Duration.zero;
  Duration _songProgress = Duration.zero;

  Duration get songDuration => _songDuration;
  Duration get songProgress => _songProgress;

  void setSongDurationZero() {
    _songDuration = Duration.zero;
    _songProgress = Duration.zero;
  }

  AudioModels({required this.songModels}) {
    _audioPlayer.onPlayerComplete.listen((event) {
      songModels.playNextSong();
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      _songDuration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _songProgress = position;
      notifyListeners();
    });
  }

  void seek(Duration position) {
    if (songDuration.inSeconds <= 0) return;
    try {
      _audioPlayer.seek(position);
      _songProgress = position;
    } catch (e) {
      MiscUtils.showError('Error: Unable To Seek');

    }
    notifyListeners();
  }
}
