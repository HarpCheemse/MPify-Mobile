import 'package:flutter/material.dart';
import 'package:mpify/models/settings_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

const String appVersion = "1.0.0";
const String author = "HarpCheemse";
const List<String> contributor = [];

class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'General',
              style: montserratStyle(
                context: context,
                fontWeight: FontWeight.w400,
                fontSize: 32,
              ),
            ),
        
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Darkmode',
                  style: montserratStyle(
                    context: context,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Switch(
                  value:
                      context.watch<SettingsModels>().themeMode == ThemeMode.dark,
                  activeTrackColor: Colors.green,
                  onChanged: (bool newVal) {
                    context.read<SettingsModels>().toogleTheme(newVal);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Reset Setting',
                  style: montserratStyle(
                    context: context,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                HoverButton(
                  baseColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  borderRadius: 10,
                  onPressed: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.clear();
                      MiscUtils.showSuccess('Settings Reset. Restart App To See Changes');
                    } catch (e) {
                      FolderUtils.writeLog('Error: $e. Error Reset Prefs');
                    }
                  },
                  width: 50,
                  height: 50,
                  child: Center(
                    child: Text(
                      'Reset',
                      style: montserratStyle(
                        context: context,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'About',
              style: montserratStyle(
                context: context,
                fontWeight: FontWeight.w400,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 10),
            Image.asset('assets/app_icon.png'),
            Text('Mpify', style: montserratStyle(context: context, fontSize: 30)),
            Text(
              'Version: $appVersion',
              style: montserratStyle(context: context),
            ),
            Text('Author: $author', style: montserratStyle(context: context)),
            Text(
              'License: Licensed under the MIT License',
              style: montserratStyle(context: context),
            ),
            const SizedBox(height: 10),
            HoverButton(
              baseColor: Colors.transparent,
              hoverColor: Colors.transparent,
              borderRadius: 10,
              onPressed: () async {
                final url = Uri.parse(
                  'https://github.com/HarpCheemse/MPify/blob/main/LICENSE',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.platformDefault);
                }
              },
              width: 100,
              height: 20,
              child: Text(
                'License Link',
                style: montserratStyle(
                  context: context,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 10),
            HoverButton(
              baseColor: Colors.transparent,
              hoverColor: Colors.transparent,
              borderRadius: 10,
              onPressed: () async {
                final url = Uri.parse('https://github.com/HarpCheemse/MPify');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.platformDefault);
                }
              },
              width: 100,
              height: 20,
              child: Text(
                'Github Link',
                style: montserratStyle(
                  context: context,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 10),
            HoverButton(
              baseColor: Colors.transparent,
              hoverColor: Colors.transparent,
              borderRadius: 10,
              onPressed: () async {
                final url = Uri.parse(
                  'https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=RDdQw4w9WgXcQ&start_radio=1&pp=ygUJcmljayByb2xsoAcB',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.platformDefault);
                }
                
              },
              width: 100,
              height: 20,
              child: Text(
                'Suppot Me Link',
                style: montserratStyle(
                  context: context,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
