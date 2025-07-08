import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:provider/provider.dart';

class EditLyricForm extends StatefulWidget {
  const EditLyricForm({super.key});

  @override
  State<EditLyricForm> createState() => _EditLyricFormState();
}

class _EditLyricFormState extends State<EditLyricForm> {
  final TextEditingController lyric = TextEditingController();
  @override
  void dispose() {
    lyric.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        width: 600,
        height: 700,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Stack(
          children: [
            positionedHeader(context, 30, 250, 'Edit Lyric', 18, 600, null),
            Positioned(
              left: 45,
              top: 120,
              child: SizedBox(
                width: 500,
                height: 500,
                child: TextField(
                  controller: lyric,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: montserratStyle(context: context), 
                  decoration: InputDecoration(
                    hintText: 'Pase Song Lyric Here',
                    filled: true,
                    fillColor: const Color.fromARGB(134, 95, 95, 95),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    prefixIcon: Icon(Icons.music_note_outlined, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 650,
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
                  child: Text('Cancel', style: montserratStyle(context: context)),
                ),
              ),
            ),
            Positioned(
              top: 650,
              left: 500,
              child: HoverButton(
                baseColor: Colors.transparent,
                hoverColor: Colors.transparent,
                borderRadius: 0,
                onPressed: () {
                  final songModel = context.read<SongModels>();
                  final index = songModel.currentSongIndex;
                  final backgroundSong = songModel.songsBackground;
                  final identifier = backgroundSong[index].identifier;
                  OverlayController.hideOverlay();
                  context.read<SongModels>();
                  FolderUtils.writeLyricToFolder(lyric.text, identifier);
                },
                width: 80,
                height: 40,
                child: Transform.translate(
                  offset: Offset(10, 10),
                  child: Text('Create', style: montserratStyle(context: context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
