import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/api/models/timetable.hour.dart';
import 'package:sol_connect/core/excel/models/phaseelement.dart';
import 'package:sol_connect/core/excel/validator.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/time_table_detail/arguments/time_table_detail.argument.dart';
import 'package:sol_connect/ui/screens/time_table_detail/widgets/custom_phase_card.dart';

class TimeTableDetailScreen extends ConsumerWidget {
  const TimeTableDetailScreen({Key? key}) : super(key: key);
  static final routeName = (TimeTableDetailScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    final TimeTableDetailArgument args = ModalRoute.of(context)!.settings.arguments as TimeTableDetailArgument;

    final MappedPhase? phase = args.phase;

    late TimeTableHour _timeTableHour;

    PhaseCodes? firstHalf;
    PhaseCodes? secondHalf;

    Color statusCodeColor = Colors.black38;

    _timeTableHour = args.timeTableHour;

    if (phase != null) {
      firstHalf = phase.getFirstHalf();
      secondHalf = phase.getSecondHalf();
    }

    if (_timeTableHour.lessonCode == Codes.noteacher) {
      statusCodeColor = theme.colors.noTeacher;
    } else if (_timeTableHour.lessonCode == Codes.cancelled) {
      statusCodeColor = theme.colors.cancelled;
    } else if (_timeTableHour.isIrregular) {
      statusCodeColor = theme.colors.irregular;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Stunde " + _timeTableHour.getStartTimeString() + " - " + _timeTableHour.getEndTimeString(),
            style: TextStyle(color: theme.colors.text)),
        iconTheme: IconThemeData(color: theme.colors.icon),
        backgroundColor: theme.colors.primary,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 10,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Container(
                      color: statusCodeColor,
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                      alignment: const Alignment(-1, 0),
                      child: Text(
                        _timeTableHour.subject.longName,
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
                                "Lehrer: ${_timeTableHour.teacher.longName}",
                                style: TextStyle(color: theme.colors.textInverted, fontSize: 17),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              AutoSizeText(
                                "Raum: ${_timeTableHour.room.name}",
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
                                "Typ: ${_timeTableHour.activityType}",
                                style: TextStyle(color: theme.colors.textInverted, fontSize: 17),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              AutoSizeText(
                                _timeTableHour.lessonCode.readableName.toString(),
                                style: TextStyle(
                                    color: theme.colors.textInverted,
                                    fontSize: 17,
                                    backgroundColor:
                                        _timeTableHour.lessonCode != Codes.regular ? statusCodeColor : null),
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
          _timeTableHour.lessionInformation.isNotEmpty
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
                                      _timeTableHour.lessionInformation,
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
    );
  }
}
