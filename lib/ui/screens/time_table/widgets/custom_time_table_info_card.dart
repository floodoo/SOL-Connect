import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/api/models/timetable.hour.dart';
import 'package:sol_connect/core/excel/models/phaseelement.dart';
import 'package:sol_connect/core/excel/validator.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/time_table_detail/arguments/time_table_detail.argument.dart';
import 'package:sol_connect/ui/screens/time_table_detail/time_table_detail.screen.dart';

class CustomTimeTableInfoCard extends ConsumerWidget {
  const CustomTimeTableInfoCard({
    required this.timeTableHour,
    this.phase,
    this.connectTop = false,
    this.connectBottom = false,
    this.hourInfo = const <String>[],
    Key? key,
  }) : super(key: key);

  final TimeTableHour timeTableHour;
  final MappedPhase? phase;
  final bool connectTop;
  final bool connectBottom;
  final List<String> hourInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    late TimeTableHour _timeTableHour;

    Color _colorPhaseTop = theme.colors.timetableCardBackground;
    Color _colorPhaseBottom = theme.colors.timetableCardBackground;

    _timeTableHour = timeTableHour;

    if (phase != null) {
      // _timeTableHour.lessonCode != Codes.cancelled &&
      //_timeTableHour.lessonCode != Codes.irregular) {
      switch (phase!.getFirstHalf()) {
        case PhaseCodes.free:
          _colorPhaseTop =
              _timeTableHour.lessonCode != Codes.regular ? theme.colors.phaseFreeDisabled : theme.colors.phaseFree;
          break;
        case PhaseCodes.orienting:
          _colorPhaseTop = _timeTableHour.lessonCode != Codes.regular
              ? theme.colors.phaseOrientingDisabled
              : theme.colors.phaseOrienting;
          break;
        case PhaseCodes.reflection:
          _colorPhaseTop = _timeTableHour.lessonCode != Codes.regular
              ? theme.colors.phaseReflectionDisabled
              : theme.colors.phaseReflection;
          break;
        case PhaseCodes.structured:
          _colorPhaseTop = _timeTableHour.lessonCode != Codes.regular
              ? theme.colors.phaseStructuredDisabled
              : theme.colors.phaseStructured;
          break;
        case PhaseCodes.feedback:
          _colorPhaseTop = _timeTableHour.lessonCode != Codes.regular
              ? theme.colors.phaseFeedbackDisabled
              : theme.colors.phaseFeedback;
          break;
        default:
          _colorPhaseTop = theme.colors.timetableCardBackground;
      }

      switch (phase!.getSecondHalf()) {
        case PhaseCodes.free:
          _colorPhaseBottom =
              _timeTableHour.lessonCode != Codes.regular ? theme.colors.phaseFreeDisabled : theme.colors.phaseFree;
          break;
        case PhaseCodes.orienting:
          _colorPhaseBottom = _timeTableHour.lessonCode != Codes.regular
              ? theme.colors.phaseOrientingDisabled
              : theme.colors.phaseOrienting;
          break;
        case PhaseCodes.reflection:
          _colorPhaseBottom = _timeTableHour.lessonCode != Codes.regular
              ? theme.colors.phaseReflectionDisabled
              : theme.colors.phaseReflection;
          break;
        case PhaseCodes.structured:
          _colorPhaseBottom = _timeTableHour.lessonCode != Codes.regular
              ? theme.colors.phaseStructuredDisabled
              : theme.colors.phaseStructured;
          break;
        case PhaseCodes.feedback:
          _colorPhaseBottom = _timeTableHour.lessonCode != Codes.regular
              ? theme.colors.phaseFeedbackDisabled
              : theme.colors.phaseFeedback;
          break;
        default:
          _colorPhaseBottom = theme.colors.timetableCardBackground;
      }
    }

    List<Expanded> generateLessonTextWidget() {
      var expanded = <Expanded>[];
      for (String s in hourInfo) {
        expanded.add(
          Expanded(
            flex: 1,
            child: Center(
              child: AutoSizeText(
                s,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(color: theme.colors.text),
              ),
            ),
          ),
        );
      }
      return expanded;
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
                            flex: 3,
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
                                color: (_timeTableHour.lessonCode == Codes.irregular)
                                    ? theme.colors.irregular
                                    : (_timeTableHour.lessonCode == Codes.cancelled)
                                        ? theme.colors.cancelled
                                        : (!timeTableHour.hasTeacher)
                                            ? theme.colors.noTeacher
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
                            flex: 3,
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
                                color: (_timeTableHour.lessonCode == Codes.irregular)
                                    ? theme.colors.irregular
                                    : (_timeTableHour.lessonCode == Codes.cancelled)
                                        ? theme.colors.cancelled
                                        : (!timeTableHour.hasTeacher)
                                            ? theme.colors.noTeacher
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
                (timeTableHour.lessionInformation.isNotEmpty && connectTop && connectBottom == false ||
                        timeTableHour.lessionInformation.isNotEmpty &&
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
                  padding: const EdgeInsets.all(5.0),
                  child: Column(children: generateLessonTextWidget()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
