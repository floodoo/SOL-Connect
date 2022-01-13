import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
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
        return "Reflektionsphase";
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
        return "In dieser Phase spricht der Lehrer";
      case PhaseCodes.reflection:
        return "In dieser Phase macht man was wiß ich";
      case PhaseCodes.structured:
        return "In dieser Phase spricht der Lehrer";
      case PhaseCodes.free:
        return "In dieser Phase kann man machen was man will";
      case PhaseCodes.feedback:
        return "In dieser Phase macht man was weiß ich";
      default:
        return "Dieser Lehrer hat sich wohl nicht in die Excel eingetragen";
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

    PhaseCodes? firstHalf;
    PhaseCodes? secondHalf;

    if (phase != null) {
      firstHalf = phase.getFirstHalf();
      secondHalf = phase.getSecondHalf();
    }

    if (args.timeTableHour.isIrregular()) {
      _timeTableHour = args.timeTableHour.getReplacement();
    } else {
      _timeTableHour = args.timeTableHour;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Stunde " + _timeTableHour.getStartTimeString() + " - " + _timeTableHour.getEndTimeString(),
            style: TextStyle(color: theme.colors.text)),
        iconTheme: IconThemeData(color: theme.colors.icon),
        backgroundColor: theme.colors.primary,
        actions: [
          IconButton(
            icon: Icon(
              Icons.adaptive.share_rounded,
              color: theme.colors.icon,
            ),
            onPressed: () {
              ShareFilesAndScreenshotWidgets().shareScreenshot(
                previewContainer,
                MediaQuery.of(context).devicePixelRatio.toInt() * 10000,
                "TimeTableDetail",
                "TimeTableDetail.png",
                "image/png",
                text: "Shared via Untis Phasierung",
              );
            },
          )
        ],
      ),
      body: RepaintBoundary(
        key: previewContainer,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fach: ${_timeTableHour.getSubject().longName}",
                            style: TextStyle(color: theme.colors.textInverted),
                          ),
                          Text(
                            "Lehrer: ${_timeTableHour.getTeacher().longName}",
                            style: TextStyle(color: theme.colors.textInverted),
                          ),
                          Text(
                            "Raum: ${_timeTableHour.getRoom().name}",
                            style: TextStyle(color: theme.colors.textInverted),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Typ: ${_timeTableHour.getActivityType()}",
                              style: TextStyle(color: theme.colors.textInverted),
                            ),
                            Text(
                              "Status: ${_timeTableHour.getLessonCode()}",
                              style: TextStyle(color: theme.colors.textInverted),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            CustomPhaseCard(phase: firstHalf),
            CustomPhaseCard(phase: secondHalf),
          ],
        ),
      ),
    );
  }
}
