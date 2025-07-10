import 'package:flutter/material.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/create_playlist_form.dart';
import 'package:mpify/widgets/shared/scrollable/scrollable_playlist.dart';
import 'package:provider/provider.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});
  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle montserratStyleDefault = montserratStyle(context: context);
    final TextStyle montserratStyle_30 = montserratStyle(
      context: context,
      fontSize: 20,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text('Your Playlist', style: montserratStyle_30),
          const SizedBox(height: 20),
          CustomInputBar(
            controller: controller,
            onChanged: (query) {
              context.read<PlaylistModels>().updatePlaylistSearchQuery(query);
            },
            hintText: 'Search Playlist',
            fontColor: Theme.of(context).colorScheme.onSurface,
            hintColor: Theme.of(context).colorScheme.onSurface,
            searchColor: const Color.fromARGB(134, 95, 95, 95),
            iconColor: Theme.of(context).colorScheme.onSurface,
            icon: Icons.search,
          ),
          HoverButton(
            baseColor: Colors.transparent,
            hoverColor: const Color.fromARGB(105, 113, 113, 113),
            textStyle: montserratStyle(context: context),
            borderRadius: 5,
            onPressed: () {
              OverlayController.show(context, CreatePlaylistForm());
            },
            child: Row(
              children: [
                Image.asset(
                  'assets/empty_folder.png',
                  fit: BoxFit.contain,
                  width: 80,
                  height: 80,
                ),
                const SizedBox(width: 10),
                Text('New Playlist', style: montserratStyleDefault),
              ],
            ),
          ),
          ScrollableListPlaylist(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 3 / 5,
          ),
        ],
      ),
    );
  }
}
