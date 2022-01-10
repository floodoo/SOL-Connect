import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/settings/widgets/custom_settings_card.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static final routeName = (SettingsScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    bool lightMode;

    // on app start the saved appearance is loaded. This is only for the switch
    if (theme.mode == ThemeMode.light) {
      lightMode = true;
    } else {
      lightMode = false;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.black87,
        ),
        body: Container(
          color: Colors.black87,
          child: ListView(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    "Phase plan",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
              CustomSettingsCard(
                leading: const Icon(
                  Icons.add,
                  color: Colors.black87,
                ),
                text: "Add Phase Plan",
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ["xlsx"],
                    allowMultiple: false,
                  );
                  if (result != null) {
                    ref.read(timeTableService).loadPhase(result.files.first.path!);
                    Navigator.of(context).pop();
                  }
                },
              ),
              CustomSettingsCard(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.black87,
                ),
                text: "Delete Phase Plan",
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(timeTableService).deletePhase();
                },
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    "Appearance",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 0.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SwitchListTile(
                    value: lightMode,
                    onChanged: (bool value) {
                      ref.read(themeService).saveAppearence(value);
                    },
                    title: Text(
                      (theme.mode == ThemeMode.light) ? "Light Mode" : "Dark Mode",
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    "App Info",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
              CustomSettingsCard(
                leading: const Icon(
                  FontAwesome.github_circled,
                  color: Colors.black87,
                ),
                text: "Github Repo",
                onTap: () async {
                  String _url = "https://github.com/floodoo/untis_phasierung";
                  if (!await launch(_url)) {
                    throw "Could not launch $_url";
                  }
                },
              ),
              CustomSettingsCard(
                leading: const Icon(
                  Icons.info,
                  color: Colors.black87,
                ),
                text: "Build Number",
              ),
            ],
          ),
        ));
  }
}
