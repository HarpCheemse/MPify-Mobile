import 'package:audio_service/audio_service.dart';
import 'package:mpify/main.dart';
import 'package:mpify/utils/audio_ultis.dart';
import 'package:mpify/utils/misc_utils.dart';

class MyAudioHandler extends BaseAudioHandler {
  final player = AudioUtils.player;
  MyAudioHandler() {
    playbackState.add(
      PlaybackState(
        controls: [
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToPrevious,
          MediaControl.rewind,

          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: [1, 4],
        playing: true,
      ),
    );
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
  }

  @override
  Future<void> play() async {
    if (!player.playing) {
      await player.play();
      globalSongModel.setIsPlaying(true);
      globalSongModel.refresh();
    }

    playbackState.add(
      playbackState.value.copyWith(
        playing: globalSongModel.isPlaying,
        processingState: AudioProcessingState.ready,
        controls: [
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          MediaControl.pause,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: [1, 4],
      ),
    );
  }

  @override
  Future<void> pause() async {
    await player.pause();
    globalSongModel.setIsPlaying(false);
    globalSongModel.refresh();
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        playing: globalSongModel.isPlaying,
        controls: [
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          MediaControl.play,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: [1, 4],
      ),
    );
  }

  @override
  Future<void> skipToNext() async {
    globalSongModel.playNextSong();
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        playing: globalSongModel.isPlaying,
        controls: [
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: [1, 4],
      ),
    );
  }

  @override
  Future<void> skipToPrevious() async {
    globalSongModel.playPreviousSong();
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        playing: globalSongModel.isPlaying,
        controls: [
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: [1, 4],
      ),
    );
  }

  @override
  Future<void> rewind() async {
    try {
      final position = player.position;
      final newPos = position - const Duration(seconds: 5);
      await player.seek((newPos > Duration.zero) ? newPos : Duration.zero);
    } catch (e) {
      MiscUtils.showError("Unable To Fastfoward");
    }
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        playing: globalSongModel.isPlaying,
        controls: [
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: [1, 4],
      ),
    );
  }

  @override
  Future<void> fastForward() async {
    try {
      final position = player.position;
      final duration = player.duration;
      if (duration != null && position < duration) {
        await player.seek(position + const Duration(seconds: 5));
      }
    } catch (e) {
      MiscUtils.showError("Unable To Fastfoward");
    }
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        playing: globalSongModel.isPlaying,
        controls: [
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: [1, 4],
      ),
    );
  }
}
