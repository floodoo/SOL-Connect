import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sol_connect/core/api/models/schoolclass.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/excel/models/phasestatus.dart';
import 'package:sol_connect/core/excel/solc_api_manager.dart';
import 'package:sol_connect/core/excel/validator.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/time_table/time_table.screen.dart';
import 'package:sol_connect/ui/themes/app_theme.dart';
import 'package:sol_connect/util/logger.util.dart';

// ignore: must_be_immutable
class TeacherClassesScreen extends ConsumerStatefulWidget {
  TeacherClassesScreen({Key? key}) : super(key: key);
  static final routeName = (TeacherClassesScreen).toString();
  String searchString = "";

  @override
  _TeacherClassesScreenState createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends ConsumerState<TeacherClassesScreen> {
  late SearchBar searchBar;
  final Logger log = getLogger();

  SnackBar _createSnackbar(String message, Color backgroundColor,
      {required AppTheme theme, Duration duration = const Duration(seconds: 4)}) {
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

  Widget buildClasslistEntry(SchoolClass klasse, [PhaseStatus? phaseStatus]) {
    final theme = ref.watch(themeService).theme;
    final DateTime now = DateTime.now();

    if (phaseStatus != null) {
      log.i(phaseStatus.blockStart);
    }
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 10, 10),
        child: Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              //Erst mal so ne design idee. Das geht bestimmt 100 mal besser ;)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Container(
                  color: phaseStatus != null
                      ? now.millisecondsSinceEpoch < phaseStatus.blockStart.millisecondsSinceEpoch
                          ? theme.colors.phaseOrienting
                          : now.millisecondsSinceEpoch > phaseStatus.blockEnd.millisecondsSinceEpoch
                              ? theme.colors.phaseOutOfBlock
                              : theme.colors.successColor
                      : theme.colors.phaseUnknown,
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 1),
                  width: 8,
                ),
              ),
              Column(
                children: [
                  Text(klasse.displayName),
                  Text(klasse.classTeacherName),
                ],
              ),
              phaseStatus != null
                  ? Column(
                      children: [
                        Text("Phasierung aktuell von " +
                            Utils.convertToDDMMYY(phaseStatus.blockStart) +
                            " bis " +
                            Utils.convertToDDMMYY(phaseStatus.blockEnd)),
                        Text("Dateibesitzer: " + phaseStatus.fileOwnerId.toString())
                      ],
                    )
                  : const Padding(padding: EdgeInsets.all(0)),

              IconButton(
                onPressed: () async {
                  try {
                    log.d("Virtuelle Phasierung für Klasse: " + klasse.displayName + " herunterladen ...");
                    List<int> bytes =
                        await ref.read(timeTableService).apiManager!.downloadVirtualSheet(klasseId: klasse.id);

                    ref.read(timeTableService).session.setTimetableBehaviour(klasse.id, PersonTypes.klasse,
                        debug: true); //TODO(debug): Debug Stundenplan aktiviert

                    await ref.read(timeTableService).loadCheckedVirtualPhaseFileForNextBlock(bytes: bytes);
                  } catch (e) {
                    log.e(e);
                    return;
                  }
                  ref.read(timeTableService).resetTimeTable();
                  ref.read(timeTableService).weekCounter = 0;
                  ref.read(timeTableService).getTimeTable();

                  Navigator.pushNamed(context, TimeTableScreen.routeName);
                },
                icon: const Icon(Icons.remove_red_eye_rounded),
                tooltip: "Phasierung anschauen",
              ),
              IconButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ["xlsx"],
                      allowMultiple: false,
                      dialogTitle: "Phasierung hochladen: " + klasse.displayName);

                  if (result != null) {
                    final UserSession session = ref.read(timeTableService).session;
                    final SOLCApiManager manager = ref.read(timeTableService).apiManager!;

                    //Schritt 1: Verifiziere den Stundenplan für die Klasse:
                    session.setTimetableBehaviour(klasse.id, PersonTypes.klasse,
                        debug:
                            true); //ACHTUNG debug ist hier auf true weil noch kein neuer Blockstart der klasse festgestellt werden kann
                    ExcelValidator tempValidator =
                        ExcelValidator(manager, File(result.files.first.path!).readAsBytesSync());
                    log.d("Verifying sheet for class '" + klasse.displayName + "'");
                    try {
                      await tempValidator.mergeExcelWithWholeBlock(session);
                      log.d("Success");
                      session.resetTimetableBehaviour();
                    } catch (e) {
                      log.e("Failed to verify sheet: " + e.toString());
                      session.resetTimetableBehaviour();
                      return;
                    }

                    //Schritt 2: Lade die Datei auf den Server hoch
                    log.d("Uploading sheet ...");
                    try {
                      await manager.uploadSheet(
                          authenticatedUser: ref.read(timeTableService).session,
                          klasseId: klasse.id,
                          blockStart: tempValidator.getBlockStart()!, //Kann nicht null sein
                          blockEnd: tempValidator.getBlockEnd()!,
                          file: File(result.files.first.path!));
                      log.d("File uploaded");
                    } catch (e) {
                      log.e(e);
                    }
                  }
                },
                icon: const Icon(Icons.upload),
                tooltip: "Phasierung hochladen",
              )
            ],
          ),
        ));
    /*ListTile(
        title: Text(klasse.name),
        subtitle: Text(klasse.classTeacherName),
        onTap: () {
          ref.read(timeTableService).session.setTimetableBehavior(klasse.id, PersonTypes.klasse);
          ref.read(timeTableService).resetTimeTable();
          ref.read(timeTableService).weekCounter = 0;
          ref.read(timeTableService).getTimeTable();
          Navigator.pushNamed(context, TimeTableScreen.routeName);
        },
      ),*/

    /*return ListTile(
      title: Text(klasse.name),
      subtitle: Text(klasse.classTeacherName),
      onTap: () {
        ref.read(timeTableService).session.setTimetableBehavior(klasse.id, PersonTypes.klasse);
        ref.read(timeTableService).resetTimeTable();
        ref.read(timeTableService).weekCounter = 0;
        ref.read(timeTableService).getTimeTable();
        Navigator.pushNamed(context, TimeTableScreen.routeName);
      },
    );*/
  }

  @override
  void initState() {
    searchBar = SearchBar(
      setState: setState,
      onSubmitted: (String value) {
        widget.searchString = value;
        ref.read(teacherService).toggleReloading();
        setState(() {
          widget.searchString = value;
        });
        searchBar.buildDefaultAppBar(context);
      },
      showClearButton: true,
      clearOnSubmit: false,
      buildDefaultAppBar: (BuildContext context) {
        return AppBar(
          title: const Text("Ihre Klassen"),
          actions: [
            widget.searchString == ""
                ? searchBar.getSearchAction(context)
                : IconButton(
                    onPressed: () {
                      searchBar.controller.clear();
                      setState(() {
                        widget.searchString = "";
                      });
                      searchBar.buildDefaultAppBar(context);
                    },
                    icon: const Icon(Icons.clear),
                  )
          ],
        );
      },
    );
    super.initState();
  }

  Future<List<Widget>> buildAllTeacherClasses(String searchString) async {
    List<Widget> list = [];
    List<SchoolClass> allClassesAsTeacher = await ref.read(timeTableService).session.getClassesAsTeacher();
    List<SchoolClass> ownClassesAsTeacher = await ref.read(timeTableService).session.getOwnClassesAsClassteacher();

    if (searchString != "") {
      allClassesAsTeacher = allClassesAsTeacher
          .where((element) =>
              element.name.toLowerCase().replaceAll(" ", "").contains(searchString.toLowerCase().replaceAll(" ", "")))
          .toList();
      ownClassesAsTeacher.clear();
    }

    if (allClassesAsTeacher.isEmpty) {
      return list;
    }

    if (ownClassesAsTeacher.isNotEmpty) {
      list.add(
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: AutoSizeText(
              "Ihre Klassen als Klassenlehrer:in",
              style: TextStyle(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      for (var i = 0; i < ownClassesAsTeacher.length; i++) {
        list.add(
          ListTile(
            //print("");
            title: Text(ownClassesAsTeacher[i].name),
            subtitle: Text(ownClassesAsTeacher[i].classTeacherName),
            onTap: () {
              ref.read(timeTableService).session.setTimetableBehaviour(ownClassesAsTeacher[i].id, PersonTypes.klasse);
              ref.read(timeTableService).resetTimeTable();
              ref.read(timeTableService).weekCounter = 0;
              ref.read(timeTableService).getTimeTable();
              Navigator.pushNamed(context, TimeTableScreen.routeName);
            },
          ),
        );
        if (i != ownClassesAsTeacher.length - 1) {
          list.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(
                color: ref.watch(themeService).theme.colors.textInverted,
              ),
            ),
          );
        }
      }
    }

    if (allClassesAsTeacher.isNotEmpty) {
      list.add(
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: AutoSizeText(
              "Unterrichtete Klassen",
              style: TextStyle(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
      for (var i = 0; i < allClassesAsTeacher.length; i++) {
        PhaseStatus? status;
        try {
          status = await ref.read(timeTableService).apiManager!.getKlasseInfo(klasseId: allClassesAsTeacher[i].id);
        } catch (e) {
          log.e(e);
        }
        list.add(buildClasslistEntry(allClassesAsTeacher[i], status));
        if (i != allClassesAsTeacher.length - 1) {
          list.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(
                color: ref.watch(themeService).theme.colors.textInverted,
              ),
            ),
          );
        }
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeService).theme;

    return Scaffold(
      appBar: searchBar.build(context),
      body: ref.watch(teacherService).isReloading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colors.progressIndicator,
              ),
            )
          : FutureBuilder(
              future: buildAllTeacherClasses(widget.searchString),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colors.progressIndicator,
                    ),
                  );
                } else {
                  return (snapshot.data.length == 0)
                      ? Center(
                          child: Text(
                            "Keine Klassen gefunden",
                            style: TextStyle(
                              fontSize: 20,
                              color: theme.colors.textInverted,
                            ),
                          ),
                        )
                      : ListView(children: snapshot.data);
                }
              },
            ),
    );
  }
}
