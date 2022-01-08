import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';

class CustomTimeTableInfoCard extends StatefulWidget {
  const CustomTimeTableInfoCard({Key? key, required this.timeTableHour}) : super(key: key);

  final TimeTableHour timeTableHour;

  @override
  State<CustomTimeTableInfoCard> createState() => _CustomTimeTableInfoCardState();
}

class _CustomTimeTableInfoCardState extends State<CustomTimeTableInfoCard> {
  late TimeTableHour _timeTableHour;
  final Color _colorPhaseTop = Colors.green;
  final Color _colorPhaseBottom = Colors.green;

  @override
  void initState() {
    if (widget.timeTableHour.isIrregular()) {
      _timeTableHour = widget.timeTableHour.getReplacement();
    } else {
      _timeTableHour = widget.timeTableHour;
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
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                          ),
                          color: Colors.green,
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
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                          ),
                          color: Colors.green,
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
