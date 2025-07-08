import 'package:flutter/material.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/playlist_ultis.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:provider/provider.dart';

class CreateSongForm extends StatefulWidget {
  const CreateSongForm({super.key});

  @override
  State<CreateSongForm> createState() => _CreateSongFormState();
}

class _CreateSongFormState extends State<CreateSongForm> {
  final TextEditingController name = TextEditingController();
  final TextEditingController link = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        width: 600,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Stack(
          children: [
            positionedHeader(context, 30, 250, 'Create Song', 18, 600, null),
            Positioned(
              left: 45,
              top: 120,
              child: SizedBox(
                width: 500,
                height: 50,
                child: CustomInputBar(
                  onChanged: (query) {},
                  controller: name,
                  hintText: 'Song Name',
                  fontColor: Theme.of(context).colorScheme.onSurface,
                  hintColor: Theme.of(context).colorScheme.onSurface,
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: Theme.of(context).colorScheme.onSurface,
                  icon: Icons.add,
                ),
              ),
            ),
            Positioned(
              left: 45,
              top: 200,
              child: SizedBox(
                width: 500,
                height: 50,
                child: CustomInputBar(
                  onChanged: (query) {},
                  controller: link,
                  hintText: 'Song Link',
                  fontColor: Theme.of(context).colorScheme.onSurface,
                  hintColor: Theme.of(context).colorScheme.onSurface,
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: Theme.of(context).colorScheme.onSurface,
                  icon: Icons.add,
                ),
              ),
            ),
            Positioned(
              top: 340,
              left: 40,
              child: HoverButton(
                baseColor: Colors.transparent,
                hoverColor: Colors.transparent,
                borderRadius: 10,
                onPressed: () async {
                  final String selectedPlaylist = context
                      .read<PlaylistModels>()
                      .selectedPlaylist;
                  final songModels = context.read<SongModels>();
                  await FolderUtils.addCustomMP3(selectedPlaylist);
                  songModels.loadSong(selectedPlaylist);
                  OverlayController.hideOverlay();
                },
                width: 180,
                height: 40,
                child: Row(
                  children: [
                    Icon(
                      Icons.add_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    Text(
                      'Add Custome MP3',
                      style: montserratStyle(context: context),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 340,
              left: 400,
              child: HoverButton(
                baseColor: Colors.transparent,
                borderRadius: 0,
                onPressed: () {
                  OverlayController.hideOverlay();
                },
                width: 80,
                hoverColor: Colors.transparent,
                height: 40,
                child: Transform.translate(
                  offset: Offset(10, 10),
                  child: Text(
                    'Cancel',
                    style: montserratStyle(context: context),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 340,
              left: 500,
              child: HoverButton(
                baseColor: Colors.transparent,
                hoverColor: Colors.transparent,
                borderRadius: 0,
                onPressed: () async {
                  final songName = name.text;
                  final songLink = link.text;
                  final playlistModels = context.read<PlaylistModels>();
                  final songModels = context.read<SongModels>();
                  OverlayController.hideOverlay();
                  await PlaylistUltis.downloadMP3(context, songName, songLink);
                  songModels.loadSong(playlistModels.selectedPlaylist);
                },
                width: 80,
                height: 40,
                child: Transform.translate(
                  offset: Offset(10, 10),
                  child: Text(
                    'Create',
                    style: montserratStyle(context: context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
