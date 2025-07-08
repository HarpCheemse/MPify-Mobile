import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';

import 'package:mpify/utils/folder_ultis.dart';

class CreatePlaylistForm extends StatefulWidget {
  const CreatePlaylistForm({super.key});

  @override
  State<CreatePlaylistForm> createState() => _CreatePlaylistFormState();
}

class _CreatePlaylistFormState extends State<CreatePlaylistForm> {
  final TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = montserratStyle(context: context);
    final TextStyle textStyle_20 = montserratStyle(
      context: context,
      fontSize: 20,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text('New Playlist Folder', style: textStyle_20),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 60,
                  child: CustomInputBar(
                    onChanged: (query) {},
                    controller: controller,
                    hintText: 'Playlist Name',
                    fontColor: Theme.of(context).colorScheme.onSurface,
                    hintColor: Theme.of(context).colorScheme.onSurface,
                    searchColor: const Color.fromARGB(134, 95, 95, 95),
                    iconColor: Theme.of(context).colorScheme.onSurface,
                    icon: Icons.add,
                    fontSize: 16,
                  ),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HoverButton(
                    baseColor: Colors.transparent,
                    borderRadius: 10,
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
                        style: textStyle,
                      ),
                    ),
                  ),
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: 10,
                    onPressed: () {
                      final folderName = controller.text;
                      FolderUtils.createPlaylistFolder(folderName);
                      OverlayController.hideOverlay();
                    },
                    width: 80,
                    height: 40,
                    child: Transform.translate(
                      offset: Offset(10, 10),
                      child: Text(
                        'Create',
                        style: textStyle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}
