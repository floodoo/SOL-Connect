import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sol_connect/core/api/models/schoolclass.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/excel/models/phasestatus.dart';
import 'package:sol_connect/core/excel/solc_api_manager.dart';
import 'package:sol_connect/core/excel/solcresponse.dart';
import 'package:sol_connect/core/excel/validator.dart';
import 'package:sol_connect/core/exceptions.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/time_table/time_table.screen.dart';
import 'package:sol_connect/ui/themes/app_theme.dart';
import 'package:sol_connect/util/logger.util.dart';

class TeacherClassCard extends StatefulHookConsumerWidget {
  const TeacherClassCard({required this.schoolClass, this.phaseStatus, Key? key}) : super(key: key);
  final SchoolClass schoolClass;
  final PhaseStatus? phaseStatus;

  @override
  _TeacherClassCardState createState() => _TeacherClassCardState();
}

class _TeacherClassCardState extends ConsumerState<TeacherClassCard> {
  bool isLoading = false;
  bool isUploadLoading = false;

  void _createSnackbar(
      {required String message,
      required Color backgroundColor,
      required AppTheme theme,
      required BuildContext context,
      bool clearSnachbars = false,
      Duration duration = const Duration(seconds: 4)}) {
    ScaffoldMessengerState? state = ScaffoldMessenger.maybeOf(context);
    if (state != null) {
      if (clearSnachbars) {
        ScaffoldMessenger.maybeOf(context)!.clearSnackBars();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: duration,
        elevation: 20,
        backgroundColor: backgroundColor,
        content: Text(message, style: TextStyle(fontSize: 17, color: theme.colors.text)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Logger log = getLogger();
    final theme = ref.watch(themeService).theme;
    final _timeTableService = ref.read(timeTableService);
    final DateTime now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 5, 15, 5),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            isLoading = true;
          });
          try {
            _createSnackbar(
                message: "Phasierung herunterladen ...",
                backgroundColor: theme.colors.elementBackground,
                theme: theme,
                context: context,
                clearSnachbars: true,
                duration: const Duration(seconds: 15));

            log.d("Virtuelle Phasierung für schoolClass: " +
                widget.schoolClass.displayName +
                " (" +
                widget.schoolClass.id.toString() +
                ")" +
                " herunterladen ...");

            List<int> bytes =
                await ref.read(timeTableService).apiManager!.downloadVirtualSheet(schoolClassId: widget.schoolClass.id);

            // TODO(debug): Debug timeTable is inactive
            ref.read(timeTableService).session.setTimetableBehaviour(
                  widget.schoolClass.id,
                  PersonTypes.schoolClass,
                  debug: false,
                );

            _createSnackbar(
                message: "Phasierung überprüfen ...",
                backgroundColor: theme.colors.elementBackground,
                theme: theme,
                context: context,
                clearSnachbars: true,
                duration: const Duration(seconds: 15));

            await ref.read(timeTableService).loadCheckedVirtualPhaseFileForNextBlock(bytes: bytes);

            _createSnackbar(
                message: "Fertig!",
                backgroundColor: theme.colors.successColor,
                theme: theme,
                context: context,
                clearSnachbars: true);
          } on SOLCServerError catch (e) {
            if (e.response.responseCode == SOLCResponse.CODE_ENTRY_MISSING) {
              ref.read(timeTableService).session.setTimetableBehaviour(
                    widget.schoolClass.id,
                    PersonTypes.schoolClass,
                    debug: false,
                  );

              _createSnackbar(
                  message: "Noch keine Phasierung angegeben",
                  backgroundColor: theme.colors.elementBackground,
                  theme: theme,
                  context: context,
                  clearSnachbars: true);
            }
          } catch (e) {
            log.e(e);

            _createSnackbar(
                message: "Ein Fehler ist aufgetreten: $e",
                backgroundColor: theme.colors.errorBackground,
                theme: theme,
                context: context,
                clearSnachbars: true);
          }

          _timeTableService.resetTimeTable();
          _timeTableService.weekCounter = 0;
          _timeTableService.getTimeTable();

          Navigator.pushNamedAndRemoveUntil(
            context,
            TimeTableScreen.routeName,
            (Route<dynamic> route) => false,
            arguments: {"title": widget.schoolClass.displayName},
          );
        },
        onLongPress: () {
          // TODO(philipp): Implement delete phase plan
        },
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        color: widget.phaseStatus != null
                            ? now.millisecondsSinceEpoch < widget.phaseStatus!.blockStart.millisecondsSinceEpoch
                                ? theme.colors.phaseNotStartet
                                : now.millisecondsSinceEpoch > widget.phaseStatus!.blockEnd.millisecondsSinceEpoch
                                    ? theme.colors.phaseOutOfBlock
                                    : theme.colors.phaseActive
                            : theme.colors.phaseNotUploadedJet,
                        width: 13,
                        height: 65,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.schoolClass.displayName),
                        Text(widget.schoolClass.classTeacherName),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.phaseStatus != null)
                Row(
                  children: [
                    Column(
                      children: [
                        Text("Gültig von " + Utils.convertToDDMMYY(widget.phaseStatus!.blockStart)),
                        Text("bis " + Utils.convertToDDMMYY(widget.phaseStatus!.blockEnd),
                        )
                      ],
                    )
                  ],
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isUploadLoading
                          ? Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: theme.colors.progressIndicator,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.cloud_upload_rounded),
                              iconSize: 30,
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ["xlsx"],
                                    allowMultiple: false,
                                    dialogTitle: "Phasierung hochladen: " + widget.schoolClass.displayName);

                                if (result != null) {
                                  setState(() {
                                    isUploadLoading = true;
                                  });
                                  final UserSession session = ref.read(timeTableService).session;
                                  final SOLCApiManager manager = ref.read(timeTableService).apiManager!;

                                  // Step 1: Verify timetable for schoolClass:
                                  // TODO(debug): Debug timeTable is inactive
                                  session.setTimetableBehaviour(
                                    widget.schoolClass.id,
                                    PersonTypes.schoolClass,
                                    debug: false,
                                  );

                                  ExcelValidator tempValidator = ExcelValidator(
                                    manager,
                                    File(result.files.first.path!).readAsBytesSync(),
                                  );

                                  log.d("Verifying sheet for class '" + widget.schoolClass.displayName + "'");

                                  String errorMessage = "";
                                  try {
                                    _createSnackbar(
                                        message:
                                            "Phasierung für Klasse ${widget.schoolClass.displayName} überprüfen ...",
                                        backgroundColor: theme.colors.elementBackground,
                                        theme: theme,
                                        context: context,
                                        clearSnachbars: true,
                                        duration: const Duration(seconds: 15));
                                    await tempValidator.mergeExcelWithWholeBlock(session);
                                    log.d("Success");
                                    session.resetTimetableBehaviour();
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
                                  } on NextBlockStartNotInRangeException {
                                    errorMessage = "Nächster Schulblock kann noch nicht festgestellt werden";
                                  } on ExcelMergeTimetableNotFound {
                                    errorMessage =
                                        "Phasierung passt nicht zum Stundenplan der ${widget.schoolClass.displayName}";
                                  } catch (e) {
                                    log.e(e.toString());
                                    errorMessage = "Unbekannter Fehler: " + e.toString();
                                  }

                                  if (errorMessage.isNotEmpty) {
                                    _createSnackbar(
                                        message: "Überprüfung fehlgeschlagen: $errorMessage",
                                        backgroundColor: theme.colors.errorBackground,
                                        theme: theme,
                                        context: context,
                                        clearSnachbars: true,
                                        duration: const Duration(seconds: 7));

                                    log.e("Failed to verify sheet: " + errorMessage);
                                    session.resetTimetableBehaviour();

                                    setState(() {
                                      isUploadLoading = false;
                                    });

                                    return;
                                  }

                                  // Step 2: Upload file to server
                                  log.d("Uploading sheet ...");
                                  try {
                                    _createSnackbar(
                                        message: "Datei hochladen ...",
                                        backgroundColor: theme.colors.elementBackground,
                                        theme: theme,
                                        context: context,
                                        clearSnachbars: true);

                                    await manager.uploadSheet(
                                      authenticatedUser: ref.read(timeTableService).session,
                                      schoolClassId: widget.schoolClass.id,
                                      blockStart: tempValidator.getBlockStart()!, // Can't be null
                                      blockEnd: tempValidator.getBlockEnd()!,
                                      file: File(result.files.first.path!),
                                    );
                                    log.d("File uploaded");

                                    _createSnackbar(
                                        message: "Fertig!",
                                        backgroundColor: theme.colors.successColor,
                                        theme: theme,
                                        context: context,
                                        clearSnachbars: true);

                                    ref.read(teacherService).toggleReloading();
                                    await Future.delayed(const Duration(seconds: 2), () {
                                      setState(() {
                                        isUploadLoading = false;
                                      });
                                    });
                                  } catch (e) {
                                    _createSnackbar(
                                        message: "Hochladen fehlgeschlagen: ${e.toString()}",
                                        backgroundColor: theme.colors.errorBackground,
                                        theme: theme,
                                        context: context,
                                        clearSnachbars: true);
                                    log.e(e);
                                  }
                                }
                              },
                            ),
                      const SizedBox(
                        width: 15,
                      ),
                      isLoading
                          ? Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: theme.colors.progressIndicator,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.adaptive.arrow_forward_rounded,
                              size: 30,
                            ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
