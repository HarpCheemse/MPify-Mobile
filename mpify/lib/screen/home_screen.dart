import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/audio_ultis.dart';
import 'package:mpify/utils/string_ultis.dart';
import 'package:mpify/widgets/player_or_lyric.dart';
import 'package:mpify/widgets/playlist.dart';
import 'package:mpify/widgets/settings.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/scrollable/scrollable_song.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/song.dart';
import 'package:provider/provider.dart';

final PageController mainMenuPageController = PageController();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [Playlist(), Songs(), Settings()];
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    mainMenuPageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorSchemeSurface = Theme.of(context).colorScheme.surface;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorSchemeSurface,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: mainMenuPageController,
                    onPageChanged: _onPageChange,
                    children: _pages,
                  ),
                ),
                bottomNavigationBar(context),
              ],
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height / 10,
              left: 0,
              child: Selector<SongModels, bool>(
                selector: (context, models) =>
                    models.songsBackground.isNotEmpty,
                builder: (_, isPlaying, _) {
                  if (isPlaying && _selectedIndex != 2) {
                    return Positioned(
                      bottom: (MediaQuery.of(context).size.height / 10) - 10,
                      left: 0,
                      child: MiniSongPlayer(),
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomNavigationBar(BuildContext context) {
    final TextStyle textStyle = montserratStyle(context: context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavItem(
          icon: Icons.my_library_music_outlined,
          label: 'Library',
          index: 0,
          textStyle: textStyle,
          iconSize: 32,
          context: context,
        ),
        _buildNavItem(
          icon: Icons.queue_music,
          label: 'Playlist',
          index: 1,
          textStyle: textStyle,
          iconSize: 32,
          context: context,
        ),
        _buildNavItem(
          icon: Icons.settings,
          label: 'Settings',
          index: 2,
          textStyle: textStyle,
          iconSize: 32,
          context: context,
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required TextStyle textStyle,
    required double iconSize,
    required BuildContext context,
  }) {
    final isSelected = _selectedIndex == index;
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          iconSize: iconSize,
          color: isSelected
              ? Theme.of(context).colorScheme.onSurface
              : Colors.grey,
          onPressed: () => _onTap(index),
        ),
        Text(
          label,
          style: textStyle.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class MiniSongPlayer extends StatelessWidget {
  const MiniSongPlayer({super.key});
  @override
  Widget build(BuildContext context) {
    final String identifier = context.select<SongModels, String>((models) {
      final List<Song> songs = models.songsBackground;
      if (songs.isEmpty) return "None";
      return songs[models.currentSongIndex].identifier;
    });
    final String name = context.select<SongModels, String>((models) {
      final List<Song> songs = models.songsBackground;
      if (songs.isEmpty) return "None";
      return songs[models.currentSongIndex].name;
    });
    final String artist = context.select<SongModels, String>((models) {
      final List<Song> songs = models.songsBackground;
      if (songs.isEmpty) return "None";
      return songs[models.currentSongIndex].artist;
    });
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerOrLyric()),
        );
      },
      child: Selector<SongModels, Color>(
        selector: (_, models) {
          final songs = models.songsBackground;
          if (songs.isEmpty) return colorList[0];
          if (models.currentSongIndex == -1) return colorList[0];
          final String identifier = songs[models.currentSongIndex].identifier;
          final int colorIndex =
              StringUltis.getStringValue(identifier) % colorList.length;
          return colorList[colorIndex];
        },
        builder: (_, color, _) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: MediaQuery.of(context).size.height / 11,
            width: MediaQuery.of(context).size.width,
            color: color,
            child: Stack(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CoverImage(identifier: identifier),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: montserratStyle(
                              context: context,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                          ),
                          Text(
                            artist,
                            style: montserratStyle(
                              context: context,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: () {
                        final songModels = context.read<SongModels>();
                        songModels.playPreviousSong();
                      },
                    ),
                    Selector<SongModels, bool>(
                      selector: (_, models) => models.isPlaying,
                      builder: (context, isPlaying, child) {
                        return HoverButton(
                          baseColor: Colors.transparent,
                          borderRadius: 50,
                          onPressed: () {
                            isPlaying
                                ? AudioUtils.pauseSong()
                                : AudioUtils.resumeSong();
                            context.read<SongModels>().flipIsPlaying();
                          },
                          width: 40,
                          height: 40,
                          hoverColor: const Color.fromARGB(255, 150, 150, 150),
                          child: Transform.translate(
                            offset: Offset(0, 0),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next, color: Colors.white),
                      onPressed: () {
                        final songModels = context.read<SongModels>();
                        songModels.playNextSong();
                      },
                    ),
                  ],
                ),
                //Duration Bar
                Positioned(
                  bottom: 3,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Selector<SongModels, double>(
                        selector: (_, models) {
                          final int totalSecond = models.songDuration.inSeconds;
                          final int currentSecond =
                              models.songProgress.inSeconds;
                          if (totalSecond == 0) return 0;
                          return MediaQuery.of(context).size.width *
                              currentSecond /
                              totalSecond;
                        },
                        builder: (context, width, _) {
                          return Container(
                            height: 3,
                            width: width,
                            color: Colors.white,
                          );
                        },
                      ),
                      Expanded(child: Container(height: 2, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
