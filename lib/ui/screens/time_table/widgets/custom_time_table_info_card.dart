import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/excel/models/phaseelement.dart';
import 'package:untis_phasierung/core/excel/validator.dart';

class CustomTimeTableInfoCard extends StatefulWidget {
  const CustomTimeTableInfoCard({Key? key, required this.timeTableHour, this.phase}) : super(key: key);

  final TimeTableHour timeTableHour;
  final MappedPhase? phase;

  @override
  State<CustomTimeTableInfoCard> createState() => _CustomTimeTableInfoCardState();
}

class _CustomTimeTableInfoCardState extends State<CustomTimeTableInfoCard> {
  late TimeTableHour _timeTableHour;
  PhaseColor _colorPhaseTop = PhaseCodes.unknown.color;
  PhaseColor _colorPhaseBottom = PhaseCodes.unknown.color;

  @override
  void initState() {
    if (widget.timeTableHour.isIrregular()) {
      _timeTableHour = widget.timeTableHour.getReplacement();
    } else {
      _timeTableHour = widget.timeTableHour;
    }

    if (widget.phase != null) {
      _colorPhaseTop = widget.phase!.getFirstHalf().color;
      _colorPhaseBottom = widget.phase!.getSecondHalf().color;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
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
                          color: (_timeTableHour.code == Codes.irregular)
                              ? Colors.purple.shade900
                              : (_timeTableHour.code == Codes.cancelled)
                                  ? Colors.red
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
                          color: (_timeTableHour.code == Codes.irregular)
                              ? Colors.purple.shade900
                              : (_timeTableHour.code == Codes.cancelled)
                                  ? Colors.red
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    _timeTableHour.getTeacher().name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    _timeTableHour.getRoom().name,
                    style: const TextStyle(color: Colors.white),
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
