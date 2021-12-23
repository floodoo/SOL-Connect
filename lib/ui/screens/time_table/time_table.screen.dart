import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_hour_card.dart';
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
    final Logger log = getLogger();

    final args = ModalRoute.of(context)!.settings.arguments as TimetableArguments;

    List hourList = [6, 12, 18, 24, 30, 36, 42, 48];

    int timeColumnCounter = 0;
    int schoolDayCounter = 0;
    int subjectRowCounter = 0;

    if (widget._isLoading) {
      args.userSession.getTimeTableForThisWeek().then((value) {
        widget.timeTable = value;
        setState(() {
          widget._isLoading = false;
        });
        log.i("TimeTable loaded");
      });
    }

    List<Widget> buildTimeTable() {
      List<Widget> timeTableList = [];

      for (int i = 0; i < 54; i++) {
        if (hourList.contains(i)) {
          timeColumnCounter++;
        }
        // erste reihe auschließen
        if (i > 7) {
          // schultage zurücksezten
          if (schoolDayCounter >= 5) {
            schoolDayCounter = 0;
            subjectRowCounter++;
          } else {
            schoolDayCounter++;
          }
        }

        if (widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getLessonCode() ==
                Codes.regular ||
            widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getLessonCode() ==
                Codes.cancelled ||
            i == 0 ||
            i <= 5 ||
            hourList.contains(i)) {
          (i == 0)
              ? timeTableList.add(
                  CustomTimeTableCard(
                    text: "Icon",
                    icon: Icons.calendar_today,
                    center: true,
                  ),
                )
              : (i <= 5)
                  ? timeTableList.add(
                      CustomTimeTableCard(
                        text: widget.timeTable.getDays()[i - 1].getShortName(),
                        textMaxLines: 1,
                        center: true,
                      ),
                    )
                  : (hourList.contains(i))
                      ? timeTableList.add(
                          CustomTimeTableHourCard(
                            centerText: timeColumnCounter.toString(),
                            topText:
                                widget.timeTable.getDays()[0].getHours()[timeColumnCounter - 1].getStartTimeString(),
                            bottomText:
                                widget.timeTable.getDays()[0].getHours()[timeColumnCounter - 1].getEndTimeString(),
                          ),
                        )
                      : (widget.timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend())
                          ? timeTableList.add(
                              CustomTimeTableCard(
                                text: "Holiday",
                                center: true,
                                textMaxLines: 1,
                              ),
                            )
                          : (subjectRowCounter >= widget.timeTable.getDays()[schoolDayCounter].getHours().length)
                              ? timeTableList.add(
                                  Container(),
                                )
                              : timeTableList.add(
                                  CustomTimeTableCard(
                                    text:
                                        "${widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getSubject().name} \n${widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getTeacher().name} \n${widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getRoom().name}",
                                    divider: true,
                                    topColor: (widget.timeTable
                                                .getDays()[schoolDayCounter]
                                                .getHours()[subjectRowCounter]
                                                .getLessonCode() ==
                                            Codes.cancelled)
                                        ? Colors.red
                                        : Colors.black87,
                                    bottomColor: (widget.timeTable
                                                .getDays()[schoolDayCounter]
                                                .getHours()[subjectRowCounter]
                                                .getLessonCode() ==
                                            Codes.cancelled)
                                        ? Colors.red
                                        : Colors.black87,
                                  ),
                                );
        } else if (widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getLessonCode() ==
            Codes.irregular) {
          timeTableList.add(
            CustomTimeTableCard(
              text:
                  "${widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getReplacement().getSubject().name} \n${widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getReplacement().getTeacher().name} \n${widget.timeTable.getDays()[schoolDayCounter].getHours()[subjectRowCounter].getReplacement().getRoom().name}",
              topColor: Colors.purple.shade900,
              bottomColor: Colors.purple.shade900,
            ),
          );
        } else {
          timeTableList.add(
            CustomTimeTableCard(
              text: (widget.timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend()) ? "Holiday/Weekend" : "",
              center: true,
              topColor:
                  (widget.timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend()) ? Colors.blue : Colors.black87,
              bottomColor:
                  (widget.timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend()) ? Colors.blue : Colors.black87,
              textMaxLines: 2,
            ),
          );
        }
      }
      return timeTableList;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Timetable"),
        backgroundColor: Colors.black87,
      ),
      drawer: const CustomDrawer(),
      body: Container(
        color: Colors.black,
        child: widget._isLoading
            ? Container(
                color: Colors.green,
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
