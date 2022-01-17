import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/excel/models/phaseelement.dart';
import 'package:untis_phasierung/core/excel/validator.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/arguments/time_table_detail.argument.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/time_table_detail.screen.dart';

class CustomTimeTableInfoCard extends ConsumerWidget {
  const CustomTimeTableInfoCard({
    Key? key,
    required this.timeTableHour,
    this.phase,
    this.connectTop = false,
    this.connectBottom = false,
  }) : super(key: key);
  final TimeTableHour timeTableHour;
  final MappedPhase? phase;
  final bool connectTop;
  final bool connectBottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late TimeTableHour _timeTableHour;
    final theme = ref.watch(themeService).theme;
    Color _colorPhaseTop = theme.colors.primary;
    Color _colorPhaseBottom = theme.colors.primary;

    if (timeTableHour.isIrregular()) {
      _timeTableHour = timeTableHour.getReplacement();
    } else {
      _timeTableHour = timeTableHour;
    }

    if (phase != null) {
      switch (phase!.getFirstHalf()) {
        case PhaseCodes.free:
          _colorPhaseTop = theme.colors.phaseFree;
          break;
        case PhaseCodes.orienting:
          _colorPhaseTop = theme.colors.phaseOrienting;
          break;
        case PhaseCodes.reflection:
          _colorPhaseTop = theme.colors.phaseReflection;
          break;
        case PhaseCodes.structured:
          _colorPhaseTop = theme.colors.phaseStructured;
          break;
        case PhaseCodes.feedback:
          _colorPhaseTop = theme.colors.phaseFeedback;
          break;
        default:
          _colorPhaseTop = theme.colors.phaseUnknown;
      }

      switch (phase!.getSecondHalf()) {
        case PhaseCodes.free:
          _colorPhaseBottom = theme.colors.phaseFree;
          break;
        case PhaseCodes.orienting:
          _colorPhaseBottom = theme.colors.phaseOrienting;
          break;
        case PhaseCodes.reflection:
          _colorPhaseBottom = theme.colors.phaseReflection;
          break;
        case PhaseCodes.structured:
          _colorPhaseBottom = theme.colors.phaseStructured;
          break;
        case PhaseCodes.feedback:
          _colorPhaseBottom = theme.colors.phaseFeedback;
          break;
        default:
          _colorPhaseBottom = theme.colors.phaseUnknown;
      }
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          TimeTableDetailScreen.routeName,
          arguments: TimeTableDetailArgument(
            timeTableHour: timeTableHour,
            phase: phase,
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, connectTop ? 0.7 : 5, 5, connectBottom ? 0.7 : 5),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: theme.colors.primary,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top color
                    Expanded(
                      child: Row(
                        children: [
                          // Phase color
                          Expanded(
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(connectTop ? 0 : 10.0),
                                ),
                                color: _colorPhaseTop,
                              ),
                            ),
                          ),
                          // Irregular color
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(connectTop ? 0 : 10.0),
                                ),
                                color: (_timeTableHour.getLessonCode() == Codes.irregular)
                                    ? Colors.deepPurple.shade900
                                    : (_timeTableHour.getLessonCode() == Codes.cancelled)
                                        ? Colors.purpleAccent
                                        : (timeTableHour.getTeacher().name == "---")
                                            ? Colors.grey
                                            : _colorPhaseTop,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Bottom color
                    Expanded(
                      child: Row(
                        children: [
                          // Phase color
                          Expanded(
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(connectBottom ? 0 : 10.0),
                                ),
                                color: _colorPhaseBottom,
                              ),
                            ),
                          ),
                          // Irregular color
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(connectBottom ? 0 : 10.0),
                                ),
                                color: (_timeTableHour.getLessonCode() == Codes.irregular)
                                    ? Colors.deepPurple.shade900
                                    : (_timeTableHour.getLessonCode() == Codes.cancelled)
                                        ? Colors.purpleAccent
                                        : (timeTableHour.getTeacher().name == "---")
                                            ? Colors.grey
                                            : _colorPhaseBottom,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                // Info icon
                (timeTableHour.getLessionInformation().isNotEmpty && connectTop && connectBottom == false ||
                        timeTableHour.getLessionInformation().isNotEmpty &&
                            connectTop == false &&
                            connectBottom == false)
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(1, 1, 4, 4),
                          child: Icon(Icons.info, size: 15, color: theme.colors.icon),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 3.0),
                  child: (connectTop == false && connectBottom == false)
                      ? Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: AutoSizeText(
                                _timeTableHour.getSubject().name,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: TextStyle(color: theme.colors.text),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _timeTableHour.getTeacher().name,
                                style: TextStyle(color: theme.colors.text),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _timeTableHour.getRoom().name,
                                style: TextStyle(color: theme.colors.text),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: AutoSizeText(
                            (connectTop == false && connectBottom == true)
                                ? _timeTableHour.getSubject().name
                                : (connectTop == true && connectBottom == true)
                                    ? _timeTableHour.getTeacher().name
                                    : _timeTableHour.getRoom().name,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(color: theme.colors.text),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
