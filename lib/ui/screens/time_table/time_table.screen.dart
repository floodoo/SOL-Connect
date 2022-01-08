import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/core/excel/models/mergedtimetable.dart';
import 'package:untis_phasierung/core/excel/models/phaseelement.dart';
import 'package:untis_phasierung/core/excel/validator.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_day_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_info_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_hour_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/time_table.arguments.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';
import 'package:untis_phasierung/util/logger.util.dart';

// class TimeTableScreen extends StatefulWidget {
//   TimeTableScreen({Key? key}) : super(key: key);
//   static final routeName = (TimeTableScreen).toString();
//   bool _isLoading = true;

//   @override
//   State<TimeTableScreen> createState() => _TimeTableScreenState();
// }

// class _TimeTableScreenState extends State<TimeTableScreen> {
//   late TimeTableRange timeTable;
//   @override
//   Widget build(BuildContext context) {
//     final Logger log = getLogger();

//     final args = ModalRoute.of(context)!.settings.arguments as TimetableArguments;

//     int timeColumnCounter = 0;
//     int schoolDayCounter = 0;
//     List hourList = [6, 12, 18, 24, 30, 36, 42, 48];

//     MergedTimeTable? merged;
//     MappedPhase? phase;

//     if (widget._isLoading) {
//       args.userSession.getRelativeTimeTableWeek(2).then((value) async {
//         ExcelValidator validator =
//             ExcelValidator("flo-dev.me", "/Users/flo/development/privat/untis_phasierung/assets/excel/model1.xlsx");
//         await validator.mergeExcelWithTimetable(value).then((validatorValue) {
//           setState(() {
//             timeTable = value;
//             widget._isLoading = false;
//           });
//           log.i("TimeTable loaded");
//         });
//       });
//     }

//     buildTimeTable() {
//       List<Widget> timeTableList = [];

//       for (int i = 0; i < 54; i++) {
//         // don't calculate first row
//         if (i > 7) {
//           //reset counter for the first left column
//           if (schoolDayCounter >= 5) {
//             schoolDayCounter = 0;
//           } else {
//             schoolDayCounter++;
//           }
//         }

//         if (hourList.contains(i)) {
//           timeColumnCounter++;
//         }

//         if (merged != null)
//           phase = merged.getPhaseForHour(timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1]);

//         // Top left corner
//         if (i == 0) {
//           timeTableList.add(
//             const CustomTimeTableCard(
//               child: Icon(
//                 Icons.calendar_today_rounded,
//                 color: Colors.white,
//               ),
//             ),
//           );

//           // The first row
//         } else if (i <= 5) {
//           timeTableList.add(
//             CustomTimeTableDayCard(timeTableDay: timeTable.getDays()[i - 1]),
//           );

//           // Left column with hours
//         } else if (hourList.contains(i)) {
//           timeTableList.add(
//             CustomTimeTableHourCard(
//               timeTableHour: timeTable.getDays()[0].getHours()[timeColumnCounter - 1],
//             ),
//           );

//           // If holiday  or weekend
//         } else if (timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend()) {
//           timeTableList.add(
//             const CustomTimeTableCard(
//               child: Text("Holiday"),
//             ),
//           );

//           // If no subject
//         } else if (timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1].isEmpty()) {
//           timeTableList.add(const CustomTimeTableCard());

//           // subject
//         } else {
//           timeTableList.add(
//             CustomTimeTableInfoCard(
//               timeTableHour: timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1],
//               phase: phase,
//             ),
//           );
//         }
//       }
//       return timeTableList;
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Timetable"),
//         backgroundColor: Colors.black87,
//       ),
//       drawer: const CustomDrawer(),
//       body: Container(
//         color: Colors.black,
//         child: (widget._isLoading)
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                 ),
//               )
//             : GridView.count(
//                 crossAxisCount: 6,
//                 childAspectRatio: 0.5,
//                 children: buildTimeTable(),
//               ),
//       ),
//     );
//   }
// }

class TimeTableScreen extends ConsumerWidget {
  const TimeTableScreen({Key? key}) : super(key: key);
  static final routeName = (TimeTableScreen).toString();

  buildTimeTable(TimeTableRange _timeTable, MergedTimeTable? _phasedTimeTable) {
    List<Widget> timeTableList = [];
    int timeColumnCounter = 0;
    int schoolDayCounter = 0;
    List hourList = [6, 12, 18, 24, 30, 36, 42, 48];

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
          const CustomTimeTableCard(
            child: Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
            ),
          ),
        );

        // The first row
      } else if (i <= 5) {
        timeTableList.add(
          CustomTimeTableDayCard(timeTableDay: _timeTable.getDays()[i - 1]),
        );

        // Left column with hours
      } else if (hourList.contains(i)) {
        timeTableList.add(
          CustomTimeTableHourCard(
            timeTableHour: _timeTable.getDays()[0].getHours()[timeColumnCounter - 1],
          ),
        );

        // If holiday  or weekend
      } else if (_timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend()) {
        timeTableList.add(
          const CustomTimeTableCard(
            child: Text("Holiday"),
          ),
        );

        // If no subject
      } else if (_timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1].isEmpty()) {
        timeTableList.add(const CustomTimeTableCard());

        // subject
      } else {
        timeTableList.add(
          CustomTimeTableInfoCard(
            timeTableHour: _timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1],
            phase: (_phasedTimeTable != null)
                ? _phasedTimeTable
                    .getPhaseForHour(_timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1])
                : null,
          ),
        );
      }
    }
    return timeTableList;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _timeTable = ref.watch(timeTableService).timeTable;
    final _phaseTimeTable = ref.watch(timeTableService).phaseTimeTable;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Timetable"),
        backgroundColor: Colors.black87,
      ),
      drawer: const CustomDrawer(),
      body: Container(
        color: Colors.black,
        child: (_timeTable == null)
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : GridView.count(
                crossAxisCount: 6,
                childAspectRatio: 0.5,
                children: buildTimeTable(_timeTable, _phaseTimeTable),
              ),
      ),
    );
  }
}
