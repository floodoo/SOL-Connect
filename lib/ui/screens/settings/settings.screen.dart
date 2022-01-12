import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/settings/widgets/custom_settings_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untis_phasierung/util/logger.util.dart';
import '../../../core/exceptions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static final routeName = (SettingsScreen).toString();
   
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    bool lightMode;
    Logger log = getLogger();

    // on app start the saved appearance is loaded. This is only for the switch
    if (theme.mode == ThemeMode.light) {
      lightMode = true;
    } else {
      lightMode = false;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings', style: TextStyle(color: theme.colors.text)),
          backgroundColor: theme.colors.primary,
          leading: BackButton(
            color: theme.colors.icon,
          ),
        ),
        body: Container(
          color: theme.colors.background,
          child: ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Text(
                    "Phase plan",
                    style: TextStyle(fontSize: 25, color: theme.colors.textInverted),
                  ),
                ),
              ),
              CustomSettingsCard(
                leading: Icon(
                  Icons.add,
                  color: theme.colors.text,
                ),
                text: "Add Phase Plan",
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ["xlsx"],
                    allowMultiple: false,
                  );
                  if (result != null) {
                    //Light und darkmode beachten
                    
                    String errorMessage = "";
                    try {
                      await ref.read(timeTableService).loadPhase(result.files.first.path!);
                    } on ExcelMergeFileNotVerified {
                      errorMessage = "Kein Stundenplan in Datei gefunden!";
                    } on ExcelConversionAlreadyActive {
                      errorMessage = "Unbekannter Fehler. Bitte starte die App neu!";
                    } on ExcelConversionServerError {
                      errorMessage = "Ein ExcelServer Fehler ist aufgetreten";
                    } on FailedToEstablishExcelServerConnection {
                      errorMessage = "Bitte überprüfe deine Internetverbindung";
                    } on ExcelMergeNonSchoolBlockException {
                      //Hier egal!
                    } catch(e) {
                      errorMessage = "Unbekannter Fehler: " + e.toString();
                      log.e(e);
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      elevation: 20,
                      backgroundColor: errorMessage == "" ? theme.colors.elementBackground : theme.colors.errorBackground,
                      content: Text(
                        errorMessage == "" ? 
                          "Phasierung erfolgreich für {block} geladen!"
                        : errorMessage,
                        style: TextStyle(fontSize: 17, color: theme.colors.text)
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      )
                    ));
                  }
                  //Navigator.of(context).pop();
                },
              ),
              CustomSettingsCard(
                leading: Icon(
                  Icons.delete,
                  color: theme.colors.text,
                ),
                padTop: 10,
                text: "Delete Phase Plan",
                onTap: () {
                  //Navigator.of(context).pop();
                  ref.read(timeTableService).deletePhase();

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      elevation: 20,
                      backgroundColor: theme.colors.elementBackground,
                      content: Text(
                        "Phasierung entfernt",
                        style: TextStyle(fontSize: 17, color: theme.colors.text)
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      )
                    ));
                },
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Text(
                    "Appearance",
                    style: TextStyle(fontSize: 25, color: theme.colors.textInverted),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 0.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: theme.colors.primary,
                  child: SwitchListTile(
                    value: lightMode,
                    onChanged: (bool value) {
                      ref.read(themeService).saveAppearence(value);
                    },
                    title: Text(
                      (theme.mode == ThemeMode.light) ? "Light Mode" : "Dark Mode",
                      maxLines: 1,
                      style: TextStyle(color: theme.colors.text),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    inactiveThumbColor: theme.colors.text,
                    activeTrackColor: theme.colors.background,
                    activeColor: theme.colors.text,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Text(
                    "App Info",
                    style: TextStyle(fontSize: 25, color: theme.colors.textInverted),
                  ),
                ),
              ),
              CustomSettingsCard(
                leading: Icon(
                  FontAwesome.github_circled,
                  color: theme.colors.text,
                ),
                text: "Github Project",
                onTap: () async {
                  String _url = "https://github.com/floodoo/untis_phasierung";
                  if (!await launch(_url)) {
                    throw "Could not launch $_url";
                  }
                },
              ),
              CustomSettingsCard(
                leading: Icon(
                  FontAwesome.github_circled,
                  color: theme.colors.text,
                ),
                padTop: 10,
                text: "Report Bug",
                onTap: () async {
                  String _url = "https://github.com/floodoo/untis_phasierung/issues/new?assignees=&labels=bug&title=Untis%20Phasierung%20Fehlerbericht";
                  if (!await launch(_url)) {
                    throw "Could not launch $_url";
                  }
                },
              ),
              CustomSettingsCard(
                leading: Icon(
                  Icons.info,
                  color: theme.colors.text,
                ),
                padTop: 10,
                text: "Build Number",
              ),
            ],
          ),
        ));
  }
}
