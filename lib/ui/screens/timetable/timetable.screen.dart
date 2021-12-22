import 'package:flutter/material.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/ui/screens/timetable/widgets/timeTable.arguments.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';
import 'package:untis_phasierung/util/logger.util.dart';

class TimeTableScreen extends StatefulWidget {
  TimeTableScreen({Key? key}) : super(key: key);
  static final routeName = (TimeTableScreen).toString();
  late TimeTableRange timeTable;
  bool _isLoading = true;

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  @override
  Widget build(BuildContext context) {
    final log = getLogger();
    final args = ModalRoute.of(context)!.settings.arguments as TimetableArguments;
    // args.userSession.getTimeTableForThisWeek().then((value) => {
    //       print(value.getDays()[0].dayName),
    //       timeTable = value,
    //       // print(value.getDays()[0].hours[0].getTeacher().longName),
    //     });
    if (widget._isLoading) {
      args.userSession.getTimeTableForThisWeek().then((value) {
        // print(value.getDays()[0].dayName);
        widget.timeTable = value;
        setState(() {
          widget._isLoading = false;
        });
      });
    }
    int hourCounter = 0;
    int schoolDays = 0;
    int subjectRowCounter = 0;
    List hourList = [6, 12, 18, 24, 30, 36, 42, 48];

    return Scaffold(
        appBar: AppBar(
          title: const Text("Timetable"),
        ),
        drawer: const CustomDrawer(),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 54,
                      itemBuilder: (context, index) {
                        if (hourList.contains(index)) {
                          hourCounter++;
                        }
                        // erste reihe auschließen
                        if (index > 7) {
                          // schultage zurücksezten
                          if (schoolDays >= 5) {
                            schoolDays = 0;
                            subjectRowCounter++;
                          } else {
                            schoolDays++;
                          }
                        }

                        return widget._isLoading
                            ? Container(
                                color: Colors.green,
                              )
                            : Container(
                                color: Colors.blue,
                                child: (index == 0)
                                    ? const Icon(Icons.calendar_today)
                                    : (index <= 5)
                                        ? Text(
                                            "${widget.timeTable.getDays()[index - 1].getDayName()} ${widget.timeTable.getDays()[index - 1].getDate()}")
                                        : (hourList.contains(index))
                                            ? Text("$hourCounter")
                                            : (index + 7 > 54)
                                                ? const Text("test")
                                                : (widget.timeTable.getDays()[schoolDays].isHolidayOrWeekend())
                                                    ? Text("Holiday")
                                                    : (subjectRowCounter >=
                                                            widget.timeTable.getDays()[schoolDays].getHours().length)
                                                        ? Text("")
                                                        : Text(
                                                            "${widget.timeTable.getDays()[schoolDays].getHours()[subjectRowCounter].getSubject().name} {teacher} {room}"),
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
