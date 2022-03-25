import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/excel/models/phasestatus.dart';
import 'package:sol_connect/core/excel/solc_api_manager.dart';
import 'package:sol_connect/core/excel/solcresponse.dart';
import 'package:sol_connect/core/exceptions.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/settings/widgets/custom_settings_card.dart';
import 'package:sol_connect/ui/screens/settings/widgets/developer_options.dart';
import 'package:sol_connect/ui/screens/settings/widgets/info_dialog.dart';
import 'package:sol_connect/ui/shared/created_by.text.dart';
import 'package:sol_connect/util/logger.util.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  SettingsScreen({Key? key}) : super(key: key);
  static final routeName = (SettingsScreen).toString();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = getLogger();

    final theme = ref.watch(themeService).theme;
    final phaseLoaded = ref.watch(timeTableService).isPhaseVerified;
    final validator = ref.watch(timeTableService).validator;

    bool lightMode;
    bool working = false;

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

    if (ref.watch(settingsService).showDeveloperOptions) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 50,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
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
                  controller: scrollController,
                  children: [
                    Visibility(
                      visible: ref.read(timeTableService).session.personType != PersonTypes.teacher,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Phasierung",
                                style: TextStyle(fontSize: 25),
                              ),
                              InfoDialog(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: ref.read(timeTableService).session.personType != PersonTypes.teacher &&
                            !ref.read(timeTableService).isPhaseVerified,
                        child: CustomSettingsCard(
                          padBottom: 5,
                          leading: Icon(
                            Icons.file_download,
                            color: theme.colors.text,
                            size: 26,
                          ),
                          text: "Phasierung herunterladen",
                          onTap: () async {
                            if (working) {
                              return;
                            }

                            working = true;
                            final SOLCApiManager manager = ref.read(timeTableService).apiManager!;
                            final int schoolClassId = ref.read(timeTableService).session.schoolClassId;
                            ScaffoldMessenger.of(context).clearSnackBars();

                            //Schritt 1: Überprüfe ob die herunterzuladene Datei noch aktuell ist / existiert#
                            ScaffoldMessenger.of(context).showSnackBar(
                              _createSnackbar(
                                  "Überprüfe, ob eine Phasierung verfügbar ist ...", theme.colors.elementBackground,
                                  duration: const Duration(seconds: 10)),
                            );
                            log.d("Checking file status on server ...");
                            try {
                              PhaseStatus? status = await manager.getSchoolClassInfo(schoolClassId: schoolClassId);
                              if (!Utils.dateInbetweenDays(from: status!.blockStart, to: status.blockEnd)) {
                                log.e("Phasierung nicht mehr aktuell!");
                                working = false;
                                return;
                              }
                            } on SOLCServerError catch (e) {
                              log.e("Server Error: $e");
                              if (e.response.responseCode == SOLCResponse.CODE_FILE_MISSING ||
                                  e.response.responseCode == SOLCResponse.CODE_ENTRY_MISSING) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  _createSnackbar(
                                      "Keine Phasierung für deine Klasse gefunden.\nBitte frage einen deiner Lehrer ob er die Phasierung für deine Klasse bereitstellen kann.",
                                      theme.colors.elementBackground,
                                      duration: const Duration(seconds: 10)),
                                );
                              }
                              working = false;
                              return;
                            } on FailedToEstablishSOLCServerConnection {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                _createSnackbar(
                                    "Bitte überprüfe deine Internetverbindung", theme.colors.errorBackground),
                              );
                              working = false;
                              return;
                            } catch (e) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                _createSnackbar(
                                    "Ein unbekannter Fehler ist aufgetreten: $e", theme.colors.errorBackground,
                                    duration: const Duration(seconds: 10)),
                              );
                              working = false;
                              return;
                            }

                            //Schritt 2: Downloade die Phasierung
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              _createSnackbar("Phasierung herunterladen ...", theme.colors.elementBackground),
                            );
                            log.d("Downloading sheet for class " + schoolClassId.toString() + " ...");
                            List<int> bytes;
                            try {
                              bytes = await manager.downloadVirtualSheet(schoolClassId: schoolClassId);
                            } catch (e) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                _createSnackbar(
                                    "Ein unerwarteter Serverfehler ist aufgetreten: ($e)", theme.colors.errorBackground,
                                    duration: const Duration(seconds: 8)),
                              );
                              working = false;
                              return;
                            }

                            //Schritt 3: Lade Phasierung
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              _createSnackbar("Phasierung laden ...", theme.colors.elementBackground,
                                  duration: const Duration(seconds: 15)),
                            );
                            log.d("Versuche Phasierung zu laden ...");
                            // TODO(debug): Debug timetable inactive
                            //ref
                            //   .read(timeTableService)
                            //    .session
                            //    .setTimetableBehaviour(0, PersonTypes.student, debug: true);
                            try {
                              await ref.read(timeTableService).loadCheckedVirtualPhaseFileForNextBlock(bytes: bytes);

                              ScaffoldMessenger.maybeOf(context)!.clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                _createSnackbar("Fertig!", theme.colors.successColor),
                              );
                            } on NextBlockStartNotInRangeException {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                _createSnackbar(
                                    "Phasierung konnte nicht geladen werden: Dein nächster Schulblock ist noch so lange hin, er kann noch nicht festgestellt werden. Bitte gedulde dich ein wenig.",
                                    theme.colors.errorBackground,
                                    duration: const Duration(seconds: 10)),
                              );
                            } on FailedToEstablishSOLCServerConnection {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                _createSnackbar(
                                    "Bitte überprüfe deine Internetverbindung", theme.colors.errorBackground),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                _createSnackbar(
                                    "Fehler beim laden der Phasierung: $e. Bitte Frage deinen Lehrer nach einer gültigen Phasierung.",
                                    theme.colors.errorBackground,
                                    duration: const Duration(seconds: 10)),
                              );
                            }

                            Future.delayed(const Duration(seconds: 4)).then((value) {
                              working = false;
                            });
                          },
                        )),
                    Visibility(
                      visible: ref.read(timeTableService).session.personType != PersonTypes.teacher,
                      child: CustomSettingsCard(
                        padTop: 5,
                        padBottom: 0,
                        leading: Icon(
                          phaseLoaded ? Icons.delete_rounded : Icons.folder_open_sharp,
                          color: theme.colors.text,
                          size: 26,
                        ),
                        text: phaseLoaded ? "Phasierung entfernen" : "Eigene Phasierung laden",
                        onTap: () async {
                          if (working) {
                            return;
                          }

                          if (phaseLoaded) {
                            ref.read(timeTableService).deletePhase();

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              _createSnackbar("Phasierung entfernt", theme.colors.elementBackground),
                            );
                            working = false;
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
                              await ref.read(timeTableService).loadCheckedVirtualPhaseFileForNextBlock(
                                  bytes: File(result.files.first.path!).readAsBytesSync(), persistent: true);
                            } on ExcelMergeFileNotVerified {
                              errorMessage = "Kein passender Block- Stundenplan in Datei gefunden!";
                            } on ExcelConversionAlreadyActive {
                              errorMessage = "Unbekannter Fehler. Bitte starte die App neu!";
                            } on SOLCServerError {
                              errorMessage = "Ein SOLC-API Server Fehler ist aufgetreten";
                            } on FailedToEstablishSOLCServerConnection {
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

                            Future.delayed(const Duration(seconds: 4)).then((value) {
                              working = false;
                            });
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
                                              Utils.convertToDDMM(validator.getBlockStart()) +
                                              " bis " +
                                              Utils.convertToDDMM(validator.getBlockEnd())
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
                            "Light Mode",
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
                    const DeveloperOptions(),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: CreatedByText(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
