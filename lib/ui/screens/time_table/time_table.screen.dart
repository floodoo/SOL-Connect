import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/time_table.arguments.dart';
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
    final args = ModalRoute.of(context)!.settings.arguments as TimetableArguments;
    final Logger log = getLogger();

    int timeColumnCounter = 0;
    int schoolDayCounter = 0;
    int subjectRowCounter = 0;
    List hourList = [6, 12, 18, 24, 30, 36, 42, 48];

    if (widget._isLoading) {
      args.userSession.getTimeTableForThisWeek().then((value) {
        widget.timeTable = value;
        setState(() {
          widget._isLoading = false;
        });
        log.i("TimeTable loaded");
      });
    }

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
                  child: Container(
                    color: Colors.orange,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, crossAxisSpacing: 5.0, mainAxisSpacing: 5.0, childAspectRatio: 0.5),
                      itemCount: 54,
                      itemBuilder: (context, index) {
                        if (hourList.contains(index)) {
                          timeColumnCounter++;
                        }
                        // erste reihe auschließen
                        if (index > 7) {
                          // schultage zurücksezten
                          if (schoolDayCounter >= 5) {
                            schoolDayCounter = 0;
                            subjectRowCounter++;
                          } else {
                            schoolDayCounter++;
                          }
                        }

                        return widget._isLoading
                            ? Container(
                                color: Colors.green,
                              )
                            : (index == 0)
                                ? const Icon(Icons.calendar_today)
                                : (index <= 5)
                                    ? CustomTimeTableCard(
                                        text: widget.timeTable.getDays()[index - 1].getDayName(),
                                        textMaxLines: 1,
                                      )
                                    : (hourList.contains(index))
                                        ? CustomTimeTableCard(
                                            text: timeColumnCounter.toString(),
                                            center: true,
                                          )
                                        : (widget.timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend())
                                            ? CustomTimeTableCard(
                                                text: "Holiday",
                                                center: true,
                                                textMaxLines: 1,
                                              )
                                            : (subjectRowCounter >=
                                                    widget.timeTable.getDays()[schoolDayCounter].getHours().length)
                                                ? Container()
                                                : CustomTimeTableCard(
                                                    text:
                                                        "${widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getSubject().name} \n${widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getTeacher().name} \n${widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getRoom().name}",
                                                    divider: true,
                                                  );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
