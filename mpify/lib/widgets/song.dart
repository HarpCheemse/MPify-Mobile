import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mpify/models/audio_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/scrollable/scrollable_song.dart';

import 'package:provider/provider.dart';
import 'package:mpify/models/playlist_models.dart';

import 'package:mpify/utils/audio_ultis.dart';

final GlobalKey sortByMenuKey = GlobalKey();

class Songs extends StatelessWidget {
  const Songs({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [SongHeader()]);
  }
}

class SongHeader extends StatefulWidget {
  const SongHeader({super.key});
  @override
  State<SongHeader> createState() => _SongHeader();
}

class _SongHeader extends State<SongHeader> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          //header
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 140, 255),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(159, 0, 140, 255),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/folder.png',
                      fit: BoxFit.contain,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Playlist',
                          style: montserratStyle(
                            context: context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5, width: 10),
                        Text(
                          context.watch<PlaylistModels>().selectedPlaylist,
                          style: montserratStyle(
                            context: context,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Selector<SongModels, bool>(
                    selector: (context, models) => models.isPlaying,
                    builder: (context, isPlaying, child) {
                      final songModels = context.read<SongModels>();
                      final playlistModels = context.read<PlaylistModels>();
                      return HoverButton(
                        baseColor: Colors.white,
                        borderRadius: 50,
                        onPressed: () async {
                          if (playlistModels.selectedPlaylist ==
                              playlistModels.playingPlaylist) {
                            isPlaying
                                ? AudioUtils.pauseSong()
                                : AudioUtils.resumeSong();
                            songModels.flipIsPlaying();
                          } else {
                            playlistModels.setPlayingPlaylist();
                            await songModels
                                .loadActivePlaylistSong(); //copy activeSong to background song

                            final songsBackground = songModels.songsBackground;
                            if (songsBackground.isEmpty) {
                              if (!context.mounted) return;
                              context.read<AudioModels>().setSongDurationZero();
                              await AudioUtils.stopSong();
                              return;
                            }
                            final randomIndex = Random().nextInt(
                              songsBackground.length,
                            );
                            final identifier =
                                songsBackground[randomIndex].identifier;
                            songModels.getSongIndex(identifier);
                            songModels.setIsPlaying(true);
                            final name = songsBackground[randomIndex].name;
                            final artisit = songsBackground[randomIndex].artist;
                            try {
                              if (!context.mounted) return;
                              AudioUtils.playSong(
                                songsBackground[songModels.currentSongIndex]
                                    .identifier, name, artisit
                              );
                            } catch (e) {
                              MiscUtils.showError(
                                'Error: Unable To Play Audio',
                              );
                            }
                          }
                        },
                        width: 60,
                        height: 60,
                        hoverColor: const Color.fromARGB(255, 206, 206, 206),
                        child: Selector<SongModels, bool>(
                          selector: (_, models) => models.isPlaying,
                          builder: (context, isPlaying, child) {
                            final playlistModels = context
                                .read<PlaylistModels>();
                            return AnimatedSwitcher(
                              duration: Duration(milliseconds: 150),
                              child: Icon(
                                (playlistModels.selectedPlaylist ==
                                        playlistModels.playingPlaylist)
                                    ? (isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow)
                                    : Icons.play_arrow,
                                color: Colors.black,
                                key: ValueKey(isPlaying),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    icon: Icon(Icons.shuffle_rounded),
                    color: context.watch<SongModels>().isShuffle
                        ? const Color.fromARGB(255, 44, 124, 47)
                        : Colors.white,
                    iconSize: 30,
                    onPressed: () {
                      final songModels = context.read<SongModels>();
                      songModels.isShuffle
                          ? songModels.unshuffleSongs()
                          : songModels.shuffleSongs(
                              songModels.currentSongIndex,
                            );
                      songModels.flipIsShuffle();
                    },
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    icon: const Icon(Icons.add, size: 32, color: Colors.grey),
                    onPressed: () async {
                      if (context.read<PlaylistModels>().selectedPlaylist ==
                          "Playlist Name") {
                        MiscUtils.showWarning(
                          'Warning:  Please Select A Playlist First',
                        );
                        return;
                      }
                      final String selectedPlaylist = context
                          .read<PlaylistModels>()
                          .selectedPlaylist;
                      final songModels = context.read<SongModels>();
                      await FolderUtils.addCustomMP3(selectedPlaylist);
                      songModels.loadSong(selectedPlaylist);
                      return;
                    },
                  ),
                  const Expanded(child: SizedBox()),
                  SongSortOption(),
                ],
              ),
              const SizedBox(height: 10,),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomInputBar(
              controller: controller,
              onChanged: (query) {
                context.read<SongModels>().updateSongSearchQuery(query);
              },
              hintText: 'Search Name',
              searchColor: Theme.of(context).colorScheme.surfaceContainer,
              fontColor: Theme.of(context).colorScheme.onSurface,
              hintColor: Theme.of(context).colorScheme.onSurface,
              iconColor: Theme.of(context).colorScheme.onSurface,
              icon: Icons.search,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2,
            child: ScrollableListSong(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}

class SongSortOption extends StatelessWidget {
  const SongSortOption({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<SongModels>(
      builder: (context, value, child) {
        return HoverButton(
          baseColor: Colors.transparent,
          hoverColor: Colors.transparent,
          key: sortByMenuKey,
          borderRadius: 10,
          // ignore: sort_child_properties_last
          child: Center(
            child: Text(
              'Sorted by :=',
              style: montserratStyle(
                context: context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onPressed: () async {
            final RenderBox button =
                sortByMenuKey.currentContext!.findRenderObject() as RenderBox;
            final overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            final topLeft = button.localToGlobal(
              Offset(0, 50),
              ancestor: overlay,
            );
            final bottomRight = button.localToGlobal(
              button.size.bottomRight(Offset(0, 50)),
              ancestor: overlay,
            );
            final position = RelativeRect.fromRect(
              Rect.fromPoints(topLeft, bottomRight),
              Offset.zero & overlay.size,
            );
            final selected = await showMenu(
              context: context,
              position: position,
              color: Theme.of(context).colorScheme.surface,
              items: [
                PopupMenuItem(
                  value: SortOption.newest,
                  child: Text(
                    'Newest Added',
                    style: montserratStyle(context: context),
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.lastest,
                  child: Text(
                    'Lastest Added',
                    style: montserratStyle(context: context),
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.nameAZ,
                  child: Text(
                    'Name (A-Z)',
                    style: montserratStyle(context: context),
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.nameZA,
                  child: Text(
                    'Name (Z-A)',
                    style: montserratStyle(context: context),
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.artistAZ,
                  child: Text(
                    'Artist (A-Z)',
                    style: montserratStyle(context: context),
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.artistZA,
                  child: Text(
                    'Artist (Z-A)',
                    style: montserratStyle(context: context),
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.durationLongest,
                  child: Text(
                    'Duration Longest',
                    style: montserratStyle(context: context),
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.durationShortest,
                  child: Text(
                    'Duration Shortest',
                    style: montserratStyle(context: context),
                  ),
                ),
              ],
            );
            if (selected != null) {
              if (!context.mounted) return;
              context.read<SongModels>().updateSortOption(selected);
            }
          },
          width: 120,
          height: 30,
        );
      },
    );
  }
}
