import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/excel/models/phaseelement.dart';
import 'package:untis_phasierung/core/excel/validator.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/arguments/time_table_detail.argument.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/widgets/custom_text.dart';
import 'package:untis_phasierung/ui/themes/app_theme.dart';

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

  Widget createPhaseCard(PhaseCodes? phase, AppTheme theme) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Card(
            shadowColor: Colors.black87,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Column(
                children: [
                  Container(
                    color: (phase == null ? theme.colors.phaseUnknown : phase == PhaseCodes.feedback ? theme.colors.phaseFeedback
                    : phase == PhaseCodes.free ? theme.colors.phaseFree
                    : phase == PhaseCodes.orienting ? theme.colors.phaseOrienting
                    : phase == PhaseCodes.reflection ? theme.colors.phaseOrienting
                    : phase == PhaseCodes.structured ? theme.colors.phaseStructured
                    : theme.colors.phaseUnknown),
                    padding: const EdgeInsets.fromLTRB(25, 5, 0, 5),
                    alignment: const Alignment(-1, 0),
                    child: Text(
                      phase == null ? "Keine Phasierung geladen" : phase.readableName,
                      textAlign: TextAlign.left,
                      style:  TextStyle(color: theme.colors.textInverted, fontSize: 23)
                    ), 
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
                    child: Text(
                      phase == null ? "Du kannst die Phasierung für diesen Block unter \"Einstellungen\" > \"Add Phase Plan\" laden" : phase.description,
                      textAlign: TextAlign.left,  
                      style:  TextStyle(color: theme.colors.textInverted))  
                  )
                ],
              )
            )
          )
        ) 
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    GlobalKey previewContainer = GlobalKey();
    final TimeTableDetailArgument args = ModalRoute.of(context)!.settings.arguments as TimeTableDetailArgument;
    final MappedPhase? phase = args.phase;
    late TimeTableHour _timeTableHour;
    
    PhaseCodes? firstHalf;
    PhaseCodes? secondHalf;
    
    if(phase != null) {
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
        title: Text("Stunde " + _timeTableHour.getStartTimeString() + " - " + _timeTableHour.getEndTimeString(), style: TextStyle(color: theme.colors.text)),
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
           createPhaseCard(firstHalf, theme),
           createPhaseCard(secondHalf, theme)
          ],
        ),
      ),

        /*child: Center(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: CustomText(text: _timeTableHour.getSubject().longName),
              ),
              CustomText(text: _timeTableHour.getActivityType()),
              CustomText(text: "Raum " + _timeTableHour.getRoom().name),
              CustomText(text: _timeTableHour.getLessonCode().name),
              CustomText(text: _timeTableHour.getTitle()),
              if (phase != null) CustomText(text: phase.getFirstHalf().toString()),
              if (phase != null) CustomText(text: phase.getSecondHalf().toString()),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 5,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      fillColor: theme.colors.primary,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      hintText: (_timeTableHour.getLessionInformation() != "")
                          ? _timeTableHour.getLessionInformation()
                          : "If available: additional lesson information",
                      hintStyle: TextStyle(color: theme.colors.text),
                    ),
                    maxLines: 12,
                  ),
                ),
              )
            ],
          ),
        ),*/
      
    );
  }
}
