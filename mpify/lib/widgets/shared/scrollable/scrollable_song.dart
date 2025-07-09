import 'package:flutter/material.dart';
import 'package:mpify/main.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:provider/provider.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/edit_song_form.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mpify/models/playlist_models.dart';

import 'package:mpify/utils/audio_ultis.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/confirmation.dart';
import 'package:mpify/utils/playlist_ultis.dart';

class ScrollableListSong extends StatefulWidget {
  final Color? color;
  const ScrollableListSong({super.key, this.color = Colors.white});

  @override
  State<ScrollableListSong> createState() => _ScrollableListSongState();
}

class _ScrollableListSongState extends State<ScrollableListSong> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    final playlist = context.read<PlaylistModels>().selectedPlaylist;
    context.read<SongModels>().loadSong(playlist);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      child: RawScrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        thumbColor: Theme.of(context).colorScheme.surfaceContainer,
        radius: Radius.circular(5),
        thickness: 10,
        trackVisibility: false,
        child: Selector<SongModels, List<Song>>(
          selector: (_, model) => model.songsActive,
          builder: (context, songs, child) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: songs.length + 1,
              itemBuilder: (BuildContext content, int index) {
                if (index == songs.length) {
                  return SizedBox(height: 30);
                }
                final song = songs[index];
                return SongTitle(
                  songName: song.name,
                  artist: song.artist,
                  duration: song.duration,
                  identifier: song.identifier,
                  index: index,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SongTitle extends StatelessWidget {
  final String songName;
  final String duration;
  final String artist;
  final String identifier;
  final int index;
  const SongTitle({
    super.key,
    required this.songName,
    required this.duration,
    required this.artist,
    required this.index,
    required this.identifier,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = montserratStyle(context: context);
    final TextStyle textStyle_16 = montserratStyle(
      context: context,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
    final TextStyle textStyle_12 = montserratStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      context: context,
    );
    final selectedPlaylist = context.select<PlaylistModels, String>(
      (model) => model.selectedPlaylist,
    );
    final playingPlaylist = context.select<PlaylistModels, String>(
      (model) => model.playingPlaylist,
    );
    final currentSongIdentifier = context.select<SongModels, String>((model) {
      final backgroundSong = model.songsBackground;
      final index = model.currentSongIndex;
      return (backgroundSong.isEmpty)
          ? "None"
          : backgroundSong[index].identifier;
    });
    bool isSelected =
        (selectedPlaylist == playingPlaylist) &&
        (identifier == currentSongIdentifier);

    return HoverButton(
      baseColor: (isSelected)
          ? Color.fromRGBO(158, 158, 158, 0.7)
          : Colors.transparent,
      hoverColor: const Color.fromRGBO(113, 113, 113, 0.412),
      textStyle: textStyle,
      borderRadius: 5,
      width: 320,
      height: 80,
      onPressed: () async {
        context.read<PlaylistModels>().setPlayingPlaylist();
        final songModels = context.read<SongModels>();
        await songModels
            .loadActivePlaylistSong(); //copy activeSong to background song

        final songsBackground = songModels.songsBackground;

        songModels.getSongIndex(identifier);
        songModels.setIsPlaying(true);
        try {
          AudioUtils.playSong(
            songsBackground[songModels.currentSongIndex].identifier,
          );
        } catch (e) {
          MiscUtils.showError('Error: Unable To Play Audio');
          FolderUtils.writeLog('Error: $e. Unable To Play Audio');
        }
      },
      child: Row(
        children: [
          const SizedBox(width: 10),
          Text('${index + 1}', style: textStyle_16),
          const SizedBox(width: 20),
          SizedBox(
            width: 50,
            height: 50,
            child: CoverImage(identifier: identifier),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  songName,
                  style: textStyle,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
                Text(artist, style: textStyle_12),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SongOptionMenu(
            identifier: identifier,
            songName: songName,
            artist: artist,
            textStyle: textStyle,
          ),
        ],
      ),
    );
  }
}

class SongOptionMenu extends StatelessWidget {
  final String identifier;
  final String songName;
  final String artist;
  final TextStyle textStyle;
  const SongOptionMenu({
    super.key,
    required this.identifier,
    required this.songName,
    required this.artist,
    required this.textStyle,
  });
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {},
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      color: Theme.of(context).colorScheme.surface,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          onTap: () {
            OverlayController.show(
              context,
              EditSongForm(
                playlist: context.read<PlaylistModels>().selectedPlaylist,
                identifier: identifier,
                name: songName,
                artist: artist,
              ),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 10),
              Text('edit', style: textStyle),
            ],
          ),
        ),
        PopupMenuItem<String>(
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(
                'Delete From Playlist',
                style: montserratStyle(context: context),
              ),
            ],
          ),
          onTap: () {
            final selectedPlaylist = context
                .read<PlaylistModels>()
                .selectedPlaylist;
            Future.delayed(Duration.zero, () {
              if (!context.mounted) return;
              OverlayController.show(
                context,
                Confirmation(
                  headerText: 'Delete Song',
                  warningText:
                      'This action is pernament are you sure you want to delete this song?',
                  function: () => PlaylistUltis.deleteSongFromPlaylist(
                    identifier,
                    selectedPlaylist,
                    context,
                  ),
                ),
              );
            });
          },
        ),
        PopupMenuItem<String>(
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(
                'Delete From Device',
                style: montserratStyle(context: context),
              ),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              if (!context.mounted) return;
              OverlayController.show(
                context,
                Confirmation(
                  headerText: 'Delete Song',
                  warningText:
                      'This action is pernament are you sure you want to delete this song pernamently from your device?',
                  function: () =>
                      PlaylistUltis.deleteSongFromDevice(identifier, context),
                ),
              );
            });
          },
        ),
      ],
    );
  }
}

class CoverImage extends StatefulWidget {
  final String identifier;
  final double? height;
  final double? width;
  const CoverImage({
    super.key,
    required this.identifier,
    this.height,
    this.width,
  });
  @override
  State<CoverImage> createState() => _CoverImageState();
}

class _CoverImageState extends State<CoverImage> {
  late bool imageExist;

  @override
  void initState() {
    super.initState();
    _checkImageExist();
  }

  @override
  void didUpdateWidget(covariant CoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkImageExist();
    setState(() {});
  }

  void _checkImageExist() {
    final imageFile = File(
      p.join(globalAppDocDir.path, 'cover', '${widget.identifier}.png'),
    );
    imageExist = imageFile.existsSync();
  }

  void reload() {
    setState(() {
      _checkImageExist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return imageExist
        ? SizedBox(
          width: widget.width,
          height: widget.height,
          child: Image.file(
              File(
                p.join(globalAppDocDir.path, 'cover', '${widget.identifier}.png'),
              ),
              key: UniqueKey(), //Important to clear image cached
              fit: BoxFit.cover,
            ),
        )
        : SizedBox(height: widget.height, width: widget.width, child: Image.asset('assets/placeholder.png', fit: BoxFit.contain));
  }
}
