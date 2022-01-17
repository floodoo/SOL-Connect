import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/excel/models/phaseelement.dart';
import 'package:untis_phasierung/core/excel/validator.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/arguments/time_table_detail.argument.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/widgets/custom_phase_card.dart';

extension PhaseReadables on PhaseCodes {
  String get readableName {
    switch (this) {
      case PhaseCodes.orienting:
        return "Orientierungsphase";
      case PhaseCodes.reflection:
        return "Planungsphase";
      case PhaseCodes.structured:
        return "Strukturierte Phase";
      case PhaseCodes.free:
        return "Freie Phase";
      case PhaseCodes.feedback:
        return "Feedback Phase";
      default:
        return "Keine Info verfügbar";
    }
  }

  String get description {
    switch (this) {
      case PhaseCodes.orienting:
        return "In dieser Phase spricht der Lehrer und gibt Infos für den Block / die nächsten Arbeitsauftrage.\nAußerdem wird organisatorisches erledigt.";
      case PhaseCodes.reflection:
        return "In dieser Phase setzt man seine Ziele und erstellt einen Smart Plan.\nDiese Phase kann auch zur Reflexion von Zielen genutzt werden";
      case PhaseCodes.structured:
        return "Diese Phase ist durch den Lehrer Strukturiert.\nEs gibt feste Materialien / Arbeitsformen für diese Phase.";
      case PhaseCodes.free:
        return "In dieser Phase kann man gemäß der Kann- Listen und SMART- Plänen frei Lernen.\nEs gilt keine Anwesenheitspflicht.";
      case PhaseCodes.feedback:
        return "In dieser Phase gibt man rückmeldung zum Wochen- oder Blockverlauf.";
      default:
        return "Entweder wurde für dieses Fach keine Phasierung eingetragen, oder diese Phase ist der APP unbekannt.";
    }
  }
}

class TimeTableDetailScreen extends ConsumerWidget {
  const TimeTableDetailScreen({Key? key}) : super(key: key);
  static final routeName = (TimeTableDetailScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    GlobalKey previewContainer = GlobalKey();
    final TimeTableDetailArgument args = ModalRoute.of(context)!.settings.arguments as TimeTableDetailArgument;
    final MappedPhase? phase = args.phase;
    late TimeTableHour _timeTableHour;
    final bool weekInBlock = ref.watch(timeTableService).weekInBlock;

    PhaseCodes? firstHalf;
    PhaseCodes? secondHalf;

    Color statusCodeColor = Colors.black38;

    if (phase != null) {
      firstHalf = phase.getFirstHalf();
      secondHalf = phase.getSecondHalf();
    }

    if (args.timeTableHour.isIrregular()) {
      _timeTableHour = args.timeTableHour.getReplacement();
      statusCodeColor = theme.colors.irregular;
    } else {
      _timeTableHour = args.timeTableHour;
    }

    if (_timeTableHour.getLessonCode() == Codes.cancelled) {
      statusCodeColor = theme.colors.cancelled;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Stunde " + _timeTableHour.getStartTimeString() + " - " + _timeTableHour.getEndTimeString(),
            style: TextStyle(color: theme.colors.text)),
        iconTheme: IconThemeData(color: theme.colors.icon),
        backgroundColor: theme.colors.primary,
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.adaptive.share_rounded,
        //       color: theme.colors.icon,
        //     ),
        //     onPressed: () {
        //       ShareFilesAndScreenshotWidgets().shareScreenshot(
        //         previewContainer,
        //         MediaQuery.of(context).devicePixelRatio.toInt() * 10000,
        //         "TimeTableDetail",
        //         "TimeTableDetail.png",
        //         "image/png",
        //         text: "Shared via Untis Phasierung",
        //       );
        //     },
        //   )
        // ],
      ),
      body: RepaintBoundary(
        key: previewContainer,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                elevation: 10,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      child: Container(
                        color: statusCodeColor,
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                        alignment: const Alignment(-1, 0),
                        child: Text(
                          _timeTableHour.getSubject().longName,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  "Lehrer: ${_timeTableHour.getTeacher().longName}",
                                  style: TextStyle(color: theme.colors.textInverted, fontSize: 17),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                AutoSizeText(
                                  "Raum: ${_timeTableHour.getRoom().name}",
                                  style: TextStyle(color: theme.colors.textInverted, fontSize: 17),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AutoSizeText(
                                  "Typ: ${_timeTableHour.getActivityType()}",
                                  style: TextStyle(color: theme.colors.textInverted, fontSize: 17),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                AutoSizeText(
                                  "Status: ${_timeTableHour.getLessonCode()}",
                                  style: TextStyle(color: theme.colors.textInverted, fontSize: 17),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _timeTableHour.getLessionInformation().isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 20),
                    child: Card(
                        elevation: 10,
                        child: Column(
                          children: [
                            Container(
                                color: Colors.black26,
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.fromLTRB(8, 4, 10, 5),
                                        child: Text(
                                          "Vertretungstext",
                                          style: TextStyle(fontSize: 18),
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 7, 9, 7),
                                        child: Icon(Icons.info_outline, color: theme.colors.textInverted)),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Container(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                      child: Text(
                                        _timeTableHour.getLessionInformation(),
                                      ),
                                    )))
                          ],
                        )),
                  )
                : const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
            CustomPhaseCard(phase: firstHalf),
            CustomPhaseCard(phase: secondHalf),
          ],
        ),
      ),
    );
  }
}
