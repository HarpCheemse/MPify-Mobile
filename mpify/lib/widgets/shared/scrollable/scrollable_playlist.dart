import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:mpify/utils/playlist_ultis.dart';
import 'package:mpify/utils/watcher_ultis.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:provider/provider.dart';

import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/confirmation.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:file_picker/file_picker.dart';

class ScrollableListPlaylist extends StatefulWidget {
  final double? width;
  final double? height;
  const ScrollableListPlaylist({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<ScrollableListPlaylist> createState() => _ScrollableListBoxState();
}

class _ScrollableListBoxState extends State<ScrollableListPlaylist> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Watcher.playlistWatcher(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.red,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: Consumer<PlaylistModels>(
          builder: (context, playlist, child) {
            final length = playlist.playlists.length;
            return LayoutBuilder(
              builder: (context, constraints) {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: length,
                  itemExtent: constraints.maxHeight/5,
                  itemBuilder: (BuildContext content, int index) {
                    final playlistName = playlist.playlists[index];
                    return PlaylistFolder(playlistName: playlistName);
                  },
                );
              }
            );
          },
        ),
      ),
    );
  }
}

class PlaylistFolder extends StatelessWidget {
  final String playlistName;
  const PlaylistFolder({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = montserratStyle(context: context);
    final isSelected = context.select<PlaylistModels, bool>(
      (model) => model.selectedPlaylist == playlistName,
    );
    return HoverButton(
      baseColor: (isSelected)
          ? Color.fromRGBO(158, 158, 158, 0.7)
          : Colors.transparent,
      hoverColor: const Color.fromRGBO(113, 113, 113, 0.412),
      textStyle: textStyle,
      borderRadius: 5,
      width: 320,
      height: 70,
      onPressed: () {
        // context.read<PlaylistModels>().setSelectedPlaylist(playlistName);
        // context.read<SongModels>().loadSong(playlistName);
        // Watcher.playlistSongWatcher(context, playlistName);
        MiscUtils.showWarning('Hello');
      },
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset('assets/folder.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              playlistName,
              style: textStyle,
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          PlaylistOptionMenu(playlistName: playlistName),
        ],
      ),
    );
  }
}

class PlaylistOptionMenu extends StatelessWidget {
  final String playlistName;
  const PlaylistOptionMenu({super.key, required this.playlistName});
  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = montserratStyle(context: context);
    return PopupMenuButton<String>(
      onSelected: (String value) {},
      icon: Icon(
        Icons.more_horiz,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      color: Theme.of(context).colorScheme.surface,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          child: Row(
            children: [
              Icon(
                Icons.file_open_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 10),
              Text('Open File Location', style: textStyle),
            ],
          ),
          onTap: () {
            FolderUtils.openFolderInExplorer();
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.backup_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 10),
              Text('Create A Back Up File', style: textStyle),
            ],
          ),
          onTap: () async {
            OverlayController.show(
              context,
              Confirmation(
                headerText: 'Create Backup',
                warningText: 'Are You Sure You Want To Create A Backup?',
                function: () async {
                  MiscUtils.showNotification(
                    'Attempting To Create Back Up Of $playlistName',
                  );
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (dialogContext) {
                      Future.microtask(() async {
                        final bool result = await FolderUtils.createBackupFile(
                          playlistName,
                        );
                        (result)
                            ? MiscUtils.showSuccess(
                                'Successfully Created A Back Up Of $playlistName At Backup Folder',
                              )
                            : MiscUtils.showError(
                                'Error: Unable To Create A Back Up Of $playlistName',
                              );
                        if (!context.mounted) return;

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      });
                      return AlertDialog(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                        title: Center(
                          child: Text('Please Wait A Bit', style: textStyle),
                        ),
                        content: LoadingAnimationWidget.staggeredDotsWave(
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 10,
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        PopupMenuItem(
          onTap: () async {
            final FilePickerResult? result = await FilePicker.platform
                .pickFiles(type: FileType.any, withData: true);
            if (result == null || result.files.isEmpty) {
              MiscUtils.showError('Error: No Backup File Choosen');
              FolderUtils.writeLog('Error: No Song Backup File Choosen');
              return;
            }
            if (!context.mounted) {
              MiscUtils.showWarning('Warning: Contexted Removed');
              return;
            }
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (dialogContext) {
                Future.microtask(() async {
                  await FolderUtils.importBackupFile(playlistName, result);
                  if (!context.mounted) return;
                  if (context.read<PlaylistModels>().selectedPlaylist ==
                      playlistName) {
                    context.read<SongModels>().loadSong(playlistName);
                  }
                  if (!context.mounted) return;

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                });
                return AlertDialog(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  title: Center(
                    child: Text('Please Wait A Bit', style: textStyle),
                  ),
                  content: LoadingAnimationWidget.staggeredDotsWave(
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 10,
                  ),
                );
              },
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.upload_file_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 10),
              Text('Import Backup File', style: textStyle),
            ],
          ),
        ),
        PopupMenuItem<String>(
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text('Delete Playlist', style: textStyle),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              if (!context.mounted) return;
              OverlayController.show(
                context,
                Confirmation(
                  headerText: 'Delete Playlist',
                  warningText:
                      'This action is pernament are you sure you want to delete this playlist?',
                  function: () => PlaylistUltis.deletePlaylist(playlistName),
                ),
              );
            });
          },
        ),
      ],
    );
  }
}
