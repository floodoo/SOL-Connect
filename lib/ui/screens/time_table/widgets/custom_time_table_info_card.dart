import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/excel/models/phaseelement.dart';
import 'package:untis_phasierung/core/excel/validator.dart';
import 'package:untis_phasierung/core/service/services.dart';

class CustomTimeTableInfoCard extends ConsumerWidget {
  const CustomTimeTableInfoCard({Key? key, required this.timeTableHour, this.phase}) : super(key: key);
  final TimeTableHour timeTableHour;
  final MappedPhase? phase;

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

    return Card(
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
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10.0),
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
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10.0),
                          ),
                          color: (_timeTableHour.getLessonCode() == Codes.irregular)
                              ? Colors.purple.shade800
                              : (_timeTableHour.getLessonCode() == Codes.cancelled)
                                  ? Colors.red.shade900
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
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
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
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(10.0),
                          ),
                          color: (_timeTableHour.getLessonCode() == Codes.irregular)
                              ? Colors.purple.shade800
                              : (_timeTableHour.getLessonCode() == Codes.cancelled)
                                  ? Colors.red.shade900
                                  : _colorPhaseBottom,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
            child: Column(
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
                  flex: 1,
                  child: Text(
                    _timeTableHour.getRoom().name,
                    style: TextStyle(color: theme.colors.text),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
