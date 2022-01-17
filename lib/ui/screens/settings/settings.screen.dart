import 'dart:io';

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
import '../../../core/api/models/utils.dart' as utils;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static final routeName = (SettingsScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    final phaseLoaded = ref.watch(timeTableService).phaseVerified;
    final validator = ref.watch(timeTableService).validator;

    bool lightMode;
    Logger log = getLogger();

    SnackBar _createSnackbar(String message, Color backgroundColor, {Duration duration = const Duration(seconds: 4)}) {
      return SnackBar(
        duration: duration,
        elevation: 20,
        backgroundColor: backgroundColor,
        content: Text(message, style: TextStyle(fontSize: 17, color: theme.colors.text)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
        ),
      );
    }

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
            //Row(
            //  children: [
            Center(
              child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        const TextSpan(text: "Phasierung  "),
                        WidgetSpan(child: Icon(Icons.info_outline, color: theme.colors.textInverted, size: 25))
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 25),
                  )
                  // Text(
                  //   "Phasierung",
                  //   style: TextStyle(fontSize: 25, color: theme.colors.textInverted),
                  // ),
                  ),
            ),
            //  ],
            // ),

            CustomSettingsCard(
              padBottom: 0,
              leading: Icon(
                phaseLoaded ? Icons.delete_rounded : Icons.add_chart_rounded,
                color: theme.colors.text,
                size: 26,
              ),
              text: phaseLoaded ? "Phasierung entfernen" : "Phasierung laden",
              onTap: () async {
                if (phaseLoaded) {
                  ref.read(timeTableService).deletePhase();

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    _createSnackbar(
                      "Phasierung entfernt",
                      theme.colors.elementBackground,
                    ),
                  );
                  return;
                }

                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ["xlsx"],
                    allowMultiple: false,
                    dialogTitle: "Phasierung laden");

                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    _createSnackbar(
                      "Datei Überprüfen ...",
                      theme.colors.elementBackground,
                      duration: const Duration(minutes: 1),
                    ),
                  );

                  String errorMessage = "";
                  try {
                    await ref.read(timeTableService).loadCheckedPhaseFileForNextBlock(result.files.first.path!);
                  } on ExcelMergeFileNotVerified {
                    errorMessage = "Kein passender Block- Stundenplan in Datei gefunden!";
                  } on ExcelConversionAlreadyActive {
                    errorMessage = "Unbekannter Fehler. Bitte starte die App neu!";
                  } on ExcelConversionServerError {
                    errorMessage = "Ein ExcelServer Fehler ist aufgetreten";
                  } on FailedToEstablishExcelServerConnection {
                    errorMessage = "Bitte überprüfe deine Internetverbindung";
                  } on ExcelMergeNonSchoolBlockException {
                    // Doesn't matter
                  } on SocketException {
                    errorMessage = "Bitte überprüfe deine Internetverbindung";
                  } catch (e) {
                    log.e(e.toString());
                    errorMessage = "Unbekannter Fehler: " + e.toString();
                  }

                  ScaffoldMessengerState? state = ScaffoldMessenger.maybeOf(context);
                  if (state != null) {
                    ScaffoldMessenger.maybeOf(context)!.clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      _createSnackbar(
                        errorMessage == "" ? "Phasierung für aktuellen Block geladen!" : errorMessage,
                        errorMessage == "" ? theme.colors.successColor : theme.colors.errorBackground,
                      ),
                    );
                  }
                }
              },
            ),
            phaseLoaded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(30, 6, 30, 0),
                    child: Container(
                      color: theme.colors.successColor,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 5, 10),
                          child: Text(
                              validator != null
                                  ? "Phasierung geladen für Block " +
                                      utils.convertToDDMM(validator.getBlockStart()) +
                                      " bis " +
                                      utils.convertToDDMM(validator.getBlockEnd())
                                  : "Phasierung geladen für Block ? - ?",
                              style: const TextStyle(fontSize: 13))),
                    ))
                : const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),

            /* CustomSettingsCard(
              leading: Icon(
                Icons.delete,
                color: theme.colors.text,
              ),
              padTop: 10,
              text: "Delete Phase Plan",
              onTap: () {
                ref.read(timeTableService).deletePhase();

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  _createSnackbar(
                    "Phasierung entfernt",
                    theme.colors.elementBackground,
                  ),
                );
              },
            ),*/

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
                FontAwesome.bug,
                color: theme.colors.text,
              ),
              padTop: 10,
              text: "Report Bug",
              onTap: () async {
                String _url =
                    "https://github.com/floodoo/untis_phasierung/issues/new?assignees=&labels=bug&title=Untis%20Phasierung%20Fehlerbericht";
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
              padBottom: 30,
              text: "Build Number",
            ),
          ],
        ),
      ),
    );
  }
}
