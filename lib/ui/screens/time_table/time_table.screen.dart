import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_day_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_info_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_hour_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/time_table.arguments.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';
import 'package:untis_phasierung/util/logger.util.dart';

class TimeTableScreen extends StatefulWidget {
  TimeTableScreen({Key? key}) : super(key: key);
  static final routeName = (TimeTableScreen).toString();
  bool _isLoading = true;

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  late TimeTableRange timeTable;
  @override
  Widget build(BuildContext context) {
    final Logger log = getLogger();

    final args = ModalRoute.of(context)!.settings.arguments as TimetableArguments;

    int timeColumnCounter = 0;
    int schoolDayCounter = 0;
    List hourList = [6, 12, 18, 24, 30, 36, 42, 48];


    if (widget._isLoading) {
      args.userSession.getRelativeTimeTableWeek(2).then((value) {
        setState(() {
          timeTable = value;
          widget._isLoading = false;
        });
        log.i("TimeTable loaded");
      });
    }

    List<Widget> buildTimeTable() {
      List<Widget> timeTableList = [];

      for (int i = 0; i < 54; i++) {
        // don't calculate first row
        if (i > 7) {
          //reset counter for the first left column
          if (schoolDayCounter >= 5) {
            schoolDayCounter = 0;
          } else {
            schoolDayCounter++;
          }
        }

        if (hourList.contains(i)) {
          timeColumnCounter++;
        }

        // Top left corner
        if (i == 0) {
          timeTableList.add(
            CustomTimeTableCard(
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white,
              ),
            ),
          );
          log.d("TimeTableCard: Top left corner");

          // The first row
        } else if (i <= 5) {
          timeTableList.add(
            CustomTimeTableDayCard(),
          );
          log.d("TimeTableCard: The first row");

          // Left column with hours
        } else if (hourList.contains(i)) {
          timeTableList.add(
            CustomTimeTableHourCard(
              timeTableHour: timeTable.getDays()[0].getHours()[timeColumnCounter-1],
            ),
          );
          log.d("TimeTableCard: Left column with hours");

          // If holiday  or weekend
        } else if (timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend()) {
          timeTableList.add(
            CustomTimeTableCard(
              child: const Text("Holiday"),
            ),
          );
          log.d("TimeTableCard: If holiday or weekend");

          // If no subject
        } else if (timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter-1].isEmpty()) {
          timeTableList.add(CustomTimeTableCard());
          log.d("TimeTableCard: If no subject");

          // subject
        } else {
          timeTableList.add(
            CustomTimeTableInfoCard(
              timeTableHour: timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter-1],
            ),
          );
          log.d("TimeTableCard: Subject");
        }
      }
      return timeTableList;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Timetable ${(widget._isLoading) ? "" : timeTable.getDays()[0].getDate().toString()} ${(widget._isLoading) ? "" : timeTable.getDays()[timeTable.getDays().length - 1].getDate().toString()}"),
        backgroundColor: Colors.black87,
      ),
      drawer: const CustomDrawer(),
      body: Container(
        color: Colors.black,
        child: (widget._isLoading)
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : GridView.count(
                crossAxisCount: 6,
                childAspectRatio: 0.5,
                children: buildTimeTable(),
              ),
      ),
    );
  }
}
