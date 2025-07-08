import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/edit_lyric_form.dart';
import 'package:provider/provider.dart';

import 'package:mpify/utils/string_ultis.dart';

class Lyric extends StatefulWidget {
  const Lyric({super.key});
  @override
  State<Lyric> createState() => _LyricState();
}

class _LyricState extends State<Lyric> {
  final List<Color> colorList = [
    Color.fromARGB(100, 255, 82, 82), // Red
    Color.fromARGB(100, 255, 214, 64), // Yellow
    Color.fromARGB(100, 24, 255, 255), // Cyan
    Color.fromARGB(100, 68, 137, 255), // Blue
    Color.fromARGB(100, 76, 175, 79), // Green
    Color.fromARGB(100, 255, 153, 0), // Orange
    Color.fromARGB(100, 0, 187, 212), // Teal
    Color.fromARGB(100, 156, 39, 176), // Purple
    Color.fromARGB(100, 233, 30, 99), // Pink
    Color.fromARGB(100, 158, 158, 158), // Grey
    Color.fromARGB(100, 63, 81, 181), // Indigo
    Color.fromARGB(100, 139, 195, 74), // Lime green
    Color.fromARGB(100, 255, 87, 34), // Deep orange
    Color.fromARGB(100, 3, 169, 244), // Light blue
    Color.fromARGB(100, 0, 150, 136), // Teal dark
    Color.fromARGB(100, 255, 193, 7), // Amber
    Color.fromARGB(100, 103, 58, 183), // Deep Purple
    Color.fromARGB(100, 244, 67, 54), // Strong Red
    Color.fromARGB(100, 205, 220, 57), // Lime
    Color.fromARGB(100, 0, 188, 212), // Cyan moderate
    Color.fromARGB(100, 96, 125, 139), // Blue Grey
    Color.fromARGB(100, 255, 235, 59), // Bright Yellow
    Color.fromARGB(100, 124, 77, 255), // Violet Accent
    Color.fromARGB(100, 255, 138, 128), // Soft Coral
    Color.fromARGB(100, 255, 87, 125), // Raspberry pink
    Color.fromARGB(100, 0, 200, 83), // Emerald green
    Color.fromARGB(100, 186, 104, 200), // Lavender purple
    Color.fromARGB(100, 255, 171, 64), // Soft orange
    Color.fromARGB(100, 77, 182, 172), // Aqua green
    Color.fromARGB(100, 229, 57, 53), // Crimson red
    Color.fromARGB(100, 66, 165, 245), // Sky blue
    Color.fromARGB(100, 174, 234, 0), // Neon lime
    Color.fromARGB(100, 255, 202, 40), // Golden yellow
    Color.fromARGB(100, 240, 98, 146), // Rose pink
    Color.fromARGB(100, 0, 121, 107), // Dark Teal
    Color.fromARGB(100, 244, 81, 30), // Pumpkin Orange
    Color.fromARGB(100, 121, 134, 203), // Soft Indigo
    Color.fromARGB(100, 38, 198, 218), // Bright Cyan
    Color.fromARGB(100, 156, 204, 101), // Light Green
    Color.fromARGB(100, 255, 112, 67), // Coral Orange
    Color.fromARGB(100, 100, 181, 246), // Light Sky Blue
    Color.fromARGB(100, 213, 0, 249), // Neon Purple
    Color.fromARGB(100, 255, 241, 118), // Soft Yellow
    Color.fromARGB(100, 0, 229, 255), // Electric Blue
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 20),
      child: Selector<SongModels, String?>(
        selector: (_, model) {
          final songs = model.songsBackground;
          if (songs.isEmpty) {
            return null;
          } else {
            return songs[model.currentSongIndex].identifier;
          }
        },
        builder: (context, identifier, child) {
          final colorIndex = (identifier == null)
              ? 0
              : StringUltis.getStringValue(identifier) % colorList.length;
          return AnimatedContainer(
            duration: Duration(microseconds: 500),
            curve: Curves.easeOut,
            height: 600,
            width: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: colorList[colorIndex],
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                      ),
                      child: Center(
                        child: Selector<SongModels, String>(
                          selector: (_, model) {
                            if (model.songsBackground.isEmpty) {
                              return '';
                            }
                            return model
                                .songsBackground[model.currentSongIndex]
                                .identifier;
                          },
                          builder: (context, identifier, child) {
                            return FutureBuilder<String?>(
                              future: FolderUtils.getSongLyric(identifier),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error Loading lyric');
                                } else {
                                  final lyric =
                                      snapshot.data ??
                                      'This Song Does Not Has Lyric :<. Try Add Some!';
                                  return ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black,
                                          Colors.black,
                                          Colors.transparent,
                                        ],
                                        stops: [0.0, 0.05, 0.95, 1],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(15),
                                      child: Text(
                                        lyric,
                                        style: montserratStyle(context: context),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        OverlayController.show(context, EditLyricForm());
                      },
                      icon: Icon(Icons.edit),
                      iconSize: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
