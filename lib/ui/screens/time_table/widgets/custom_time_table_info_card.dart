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
    PhaseColor _colorPhaseTop = PhaseCodes.unknown.color;
    PhaseColor _colorPhaseBottom = PhaseCodes.unknown.color;

    if (timeTableHour.isIrregular()) {
      _timeTableHour = timeTableHour.getReplacement();
    } else {
      _timeTableHour = timeTableHour;
    }

    if (phase != null) {
      _colorPhaseTop = phase!.getFirstHalf().color;
      _colorPhaseBottom = phase!.getSecondHalf().color;
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
                          color: Color.fromRGBO(_colorPhaseTop.r, _colorPhaseTop.g, _colorPhaseTop.b, 1),
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
                                  : Color.fromRGBO(_colorPhaseTop.r, _colorPhaseTop.g, _colorPhaseTop.b, 1),
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
                          color: Color.fromRGBO(_colorPhaseBottom.r, _colorPhaseBottom.g, _colorPhaseBottom.b, 1),
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
                                  : Color.fromRGBO(_colorPhaseBottom.r, _colorPhaseBottom.g, _colorPhaseBottom.b, 1),
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
