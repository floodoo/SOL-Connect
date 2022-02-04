import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/exceptions.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/settings/widgets/custom_settings_card.dart';
import 'package:sol_connect/ui/shared/created_by.text.dart';
import 'package:sol_connect/util/logger.util.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static final routeName = (SettingsScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger log = getLogger();

    final TextEditingController serverAdressTextController = TextEditingController();
    FocusNode textFieldFocus = FocusNode();

    final theme = ref.watch(themeService).theme;

    final phaseLoaded = ref.watch(timeTableService).isPhaseVerified;
    final validator = ref.watch(timeTableService).validator;
    final showDeveloperOptions = ref.watch(settingsService).showDeveloperOptions;

    bool lightMode;

    SnackBar _createSnackbar(String message, Color backgroundColor, {Duration duration = const Duration(seconds: 4)}) {
      return SnackBar(
        duration: duration,
        elevation: 20,
        backgroundColor: backgroundColor,
        content: Text(message, style: TextStyle(fontSize: 17, color: theme.colors.text)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
      );
    }

    // The saved appearance is loaded on App start. This is only for the switch.
    if (theme.mode == ThemeMode.light) {
      lightMode = true;
    } else {
      lightMode = false;
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Einstellungen', style: TextStyle(color: theme.colors.text)),
          backgroundColor: theme.colors.primary,
          leading: BackButton(color: theme.colors.icon),
        ),
        body: Container(
          color: theme.colors.background,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Visibility(
                      visible: ref.read(timeTableService).session.personType != PersonTypes.teacher,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Phasierung",
                                style: TextStyle(fontSize: 25),
                              ),
                              IconButton(
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.NO_HEADER,
                                    animType: AnimType.BOTTOMSLIDE,
                                    headerAnimationLoop: false,
                                    // title: "Was ist das?",
                                    body: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Column(
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 15),
                                            child: Text(
                                              "Die Phasierung",
                                              style: TextStyle(fontSize: 23),
                                            ),
                                          ),
                                          Text(
                                            "Die Phasierung ist eine einfache Excel Datei die deinem Stundenplan gleicht und zusätzlich die SOL Phasen des aktuellen Blocks enthält.",
                                            textAlign: TextAlign.left,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 15, top: 5),
                                            child: Text(
                                              "Welche Excel Datei?",
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Text(
                                            "Diese wird üblicherweise am anfang deines Schulblocks vorgestellt und von deinem Lehrer zur Verfügung gestellt."
                                            "\nDiesen Plan kannst du dann als Excel Datei hier laden und in deinen Stundenplan einfügen.",
                                            textAlign: TextAlign.left,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 15, top: 5),
                                            child: Text(
                                              "Ist die immer gültig?",
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Text(
                                            "Wenn du eine Phasierung laden willst, wird sie immer für den nächsten aktuellen Block geladen. "
                                            "Der gültigkeits Zeitraum wird auch grün angezeigt."
                                            "\nDu wirst benachrichtigt, wenn du noch die Phasierung eines alten Blocks geladen hast.",
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),

                                    //desc: "Die Phasierung ist eine einfache Excel Datei."
                                    //  "\n\nDiese wird üblicherweise am anfang deines Schulblocks vorgestellt und von einem Lehrer zur Verfügung gestellt."
                                    //  "\nDiesen Plan kannst du dann als Excel Datei hier laden und in deinen Stundenplan einfügen."
                                    //  "\n\n"
                                    //  ,
                                    btnOkOnPress: () {},
                                  ).show();
                                },
                                icon: Icon(
                                  Icons.info_outline,
                                  color: theme.colors.textInverted,
                                ),
                                iconSize: 25,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: ref.read(timeTableService).session.personType != PersonTypes.teacher,
                      child: CustomSettingsCard(
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
                              _createSnackbar("Phasierung entfernt", theme.colors.elementBackground),
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
                              await ref.read(timeTableService).loadCheckedPhaseFileForNextBlock(
                                  phaseFilePath: result.files.first.path!,
                                  serverAdress: ref.read(settingsService).serverAddress);
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
                                              Utils().convertToDDMM(validator.getBlockStart()) +
                                              " bis " +
                                              Utils().convertToDDMM(validator.getBlockEnd())
                                          : "Phasierung geladen für Block ? - ?",
                                      style: const TextStyle(fontSize: 13))),
                            ))
                        : const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Text(
                          "Erscheinungsbild",
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
                      text: "Github Projekt",
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
                      text: "Fehler Melden",
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
                      padBottom: 15,
                      text: "Version Alpha 1.0.1",
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25.0, bottom: (showDeveloperOptions) ? 5 : 30, right: 25.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () {
                                ref.read(settingsService).toggleDeveloperOptions();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(showDeveloperOptions ? Icons.arrow_drop_down : Icons.arrow_right_rounded,
                                      color: theme.colors.textInverted),
                                  Text("Entwickleroptionen", style: TextStyle(color: theme.colors.textInverted)),
                                ],
                              ),
                            ),
                          ),
                          showDeveloperOptions
                              ? Column(
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10.0),
                                        child: Text(
                                          "Server adresse",
                                          style: TextStyle(fontSize: 25, color: theme.colors.textInverted),
                                        ),
                                      ),
                                    ),
                                    Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      color: theme.colors.primary,
                                      child: ListTile(
                                        // Idk why but on emulator it doesn't work with PC keyboard
                                        title: TextField(
                                          focusNode: textFieldFocus,
                                          controller: serverAdressTextController,
                                          onEditingComplete: () {
                                            if (serverAdressTextController.text != "") {
                                              ref
                                                  .read(settingsService)
                                                  .saveServerAdress(serverAdressTextController.text);
                                            }
                                            serverAdressTextController.clear();
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            textFieldFocus.unfocus();
                                          },
                                          textAlignVertical: TextAlignVertical.center,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            hintText: ref.watch(settingsService).serverAddress,
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                ref.read(settingsService).saveServerAdress("flo-dev.me");
                                                FocusManager.instance.primaryFocus?.unfocus();
                                                textFieldFocus.unfocus();
                                              },
                                              icon: Icon(Icons.settings_backup_restore,
                                                  color: theme.colors.textBackground),
                                              tooltip: "Setzte Server URL zurück",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: CreatedByText(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
