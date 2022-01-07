import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';

class CustomTimeTableHourCard extends StatefulWidget {
  const CustomTimeTableHourCard({Key? key, required this.timeTableHour}) : super(key: key);

  final TimeTableHour timeTableHour;

  @override
  State<CustomTimeTableHourCard> createState() => _CustomTimeTableHourCardState();
}

class _CustomTimeTableHourCardState extends State<CustomTimeTableHourCard> {
  late int hour;

  @override
  void initState() {
    hour = widget.timeTableHour.yIndex + 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        color: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: AutoSizeText(
                    widget.timeTableHour.getStartTimeString(),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  hour.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    widget.timeTableHour.getEndTimeString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
