import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untis_phasierung/core/api/models/timetable.day.dart';

class CustomTimeTableDayCard extends StatelessWidget {
  const CustomTimeTableDayCard({Key? key, required this.timeTableDay}) : super(key: key);
  final TimeTableDay timeTableDay;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeTableDay.getShortName(),
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  DateFormat("dd").format(
                    timeTableDay.getDate(),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          )),
    );
  }
}
