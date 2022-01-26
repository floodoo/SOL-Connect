import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:sol_connect/core/api/models/timetable.hour.dart';
import 'package:sol_connect/core/api/timetable.dart';
import 'package:sol_connect/core/excel/models/mergedtimetable.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/time_table/widgets/custom_time_table_card.dart';
import 'package:sol_connect/ui/screens/time_table/widgets/custom_time_table_day_card.dart';
import 'package:sol_connect/ui/screens/time_table/widgets/custom_time_table_hour_card.dart';
import 'package:sol_connect/ui/screens/time_table/widgets/custom_time_table_info_card.dart';
import 'package:sol_connect/ui/shared/custom_drawer.dart';
import 'package:sol_connect/ui/themes/app_theme.dart';

class TimeTableScreen extends ConsumerWidget {
  const TimeTableScreen({Key? key}) : super(key: key);
  static final routeName = (TimeTableScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    final _timeTableService = ref.read(timeTableService);
    final _isDebugTimetable = ref.read(timeTableService).session.isDemoSession();

    List<Widget> buildFirstTimeTableRow(TimeTableRange _timeTable, AppTheme theme) {
      List<Widget> timeTableList = [];
      for (int i = 0; i <= 5; i++) {
        // Icon in the top right corner
        if (i == 0) {
          timeTableList.add(
            CustomTimeTableCard(
              child: Icon(
                Icons.calendar_today_rounded,
                color: theme.colors.icon,
              ),
              color: theme.colors.primaryLight,
            ),
          );

          // The first row
        } else {
          timeTableList.add(
            CustomTimeTableDayCard(timeTableDay: _timeTable.getDays()[i - 1], cardColor: theme.colors.primaryLight),
          );
        }
      }
      return timeTableList;
    }

    List<Widget> buildTimeTable(
      TimeTableRange _timeTable,
      MergedTimeTable? _phasedTimeTable,
      AppTheme theme,
      BuildContext context,
    ) {
      List<Widget> timeTableList = [];
      int timeColumnCounter = 0;
      int schoolDayCounter = 0;

      for (int i = 6; i < 6 * _timeTable.schoolDayLength + 6; i++) {
        // don't calculate first row
        if (i > 7) {
          //reset counter for the first left column
          if (schoolDayCounter >= 5) {
            schoolDayCounter = 0;
          } else {
            schoolDayCounter++;
          }
        }

        if (i % 6 == 0) {
          timeColumnCounter++;
        }

        // left column with hours
        if (i % 6 == 0) {
          timeTableList.add(
            CustomTimeTableHourCard(
              timeTableHour: _timeTable.getDays()[0].getHours()[timeColumnCounter - 1],
              customColor: theme.colors.primaryLight,
            ),
          );

          // If holiday  or weekend
        } else if (_timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend()) {
          timeTableList.add(
            CustomTimeTableCard(
              child: const Text("Holiday"),
              color: theme.colors.phaseUnknown,
            ),
          );

          // If no subject
        } else if (_timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1].isEmpty()) {
          timeTableList.add(CustomTimeTableCard(color: theme.colors.background));

          // subject
        } else {
          bool connectBottom = false;
          bool connectTop = false;
          bool doubleLesson = false;
          //bool hourBeforeLunch = false;

          TimeTableHour current = _timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1];

          if (timeColumnCounter - 1 > 0) {
            TimeTableHour prev = _timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 2];
            if (current.getTeacher().name == prev.getTeacher().name &&
                current.getSubject().longName == prev.getSubject().longName &&
                current.getStartTimeString() != "13:30") {
              //Doppelstunde!
              connectTop = true;
              doubleLesson = true;
            }
          }
          if (timeColumnCounter < _timeTable.getDays()[schoolDayCounter].getHours().length) {
            TimeTableHour next = _timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter];
            if (current.getTeacher().name == next.getTeacher().name &&
                current.getSubject().longName == next.getSubject().longName) {
              //Doppelstunde!
              connectBottom = true;
            }
            if (current.getEndTime().hour == 13) {
              // hourBeforeLunch = true;
              connectBottom = false;
            }
          }

          doubleLesson = !connectBottom && doubleLesson;

          bool connectedToCurrent(int index) {
            if (timeColumnCounter - 1 == index) {
              return true;
            }
            if (index < timeColumnCounter - 1) {
              for (int i = index; i < timeColumnCounter - 1; i++) {
                if (_timeTable.getDays()[schoolDayCounter].getHours()[i].getTeacher().name !=
                    current.getTeacher().name) {
                  return false;
                }
              }
            } else {
              for (int i = timeColumnCounter - 1; i < index; i++) {
                if (_timeTable.getDays()[schoolDayCounter].getHours()[i].getTeacher().name !=
                    current.getTeacher().name) {
                  return false;
                }
              }
            }
            return true;
          }

          List<String> lessonInfo = <String>[];
          int doubleLessonIndex = 0;
          int doubleLessonCount = 0;
          int counter = -1;
          String currentTeacher = current.getTeacher().name;

          for (int i = 0; i < _timeTable.schoolDayLength; i++) {
            if (_timeTable.getDays()[schoolDayCounter].getHours()[i].getTeacher().name == currentTeacher &&
                connectedToCurrent(i) &&
                _timeTable.getDays()[schoolDayCounter].getHours()[i].getLessonCode() != Codes.irregular) {
              doubleLessonCount++;
              counter++;
              if (i == timeColumnCounter - 1) {
                doubleLessonIndex = counter;
              }
            }
          }

          if (current.getLessonCode() != Codes.irregular) {
            if (doubleLessonCount == 1) {
              lessonInfo = [current.getSubject().name, current.getTeacher().name, current.getRoom().name];
            } else if (doubleLessonCount == 2) {
              if (doubleLessonIndex == 0) {
                lessonInfo = [current.getSubject().name, current.getTeacher().name];
              } else {
                lessonInfo = [current.getRoom().name];
              }
            } else if (doubleLessonCount >= 3) {
              if (doubleLessonIndex == 0) {
                lessonInfo = [current.getSubject().name];
              } else if (doubleLessonIndex == 1) {
                lessonInfo = [current.getTeacher().name];
              } else if (doubleLessonIndex == 2) {
                lessonInfo = [current.getRoom().name];
              }
            }
          } else {
            lessonInfo = [
              current.getReplacement().getSubject().name,
              current.getReplacement().getTeacher().name,
              current.getReplacement().getRoom().name
            ];
          }
          timeTableList.add(
            CustomTimeTableInfoCard(
              timeTableHour: current,
              phase: (_phasedTimeTable != null)
                  ? _phasedTimeTable
                      .getPhaseForHour(_timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1])
                  : null,
              connectBottom: connectBottom,
              connectTop: connectTop,
              hourInfo: lessonInfo,
            ),
          );
        }
      }
      return timeTableList;
    }

    return Scaffold(
      appBar: AppBar(
        title: _isDebugTimetable
            ? RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(text: "Stundenplan    ", style: TextStyle(fontSize: 19)),
                    WidgetSpan(
                      child: Icon(Icons.warning, size: 19, color: Colors.orange.shade600),
                    ),
                    TextSpan(text: " Debug Session", style: TextStyle(color: Colors.orange.shade600, fontSize: 19)),
                  ],
                ),
              )
            : Text("Stundenplan", style: TextStyle(color: theme.colors.text)),
        iconTheme: IconThemeData(color: theme.colors.icon),
        backgroundColor: theme.colors.primary,
        actions: [
          IconButton(
            onPressed: () {
              _timeTableService.resetWeekCounter();
              _timeTableService.resetTimeTable();
              _timeTableService.getTimeTable();
            },
            icon: const Icon(Icons.today),
            tooltip: "Spring zur aktuellen Woche",
          )
        ],
      ),
      drawer: const CustomDrawer(),
      body: GestureDetector(
        onHorizontalDragEnd: (dragEndDetails) {
          if (dragEndDetails.primaryVelocity! < 0) {
            // Next page
            _timeTableService.resetTimeTable();
            _timeTableService.getTimeTableNextWeek();
          } else if (dragEndDetails.primaryVelocity! > 0) {
            // Previous page
            _timeTableService.resetTimeTable();
            _timeTableService.getTimeTablePreviousWeek();
          }
        },
        child: LiquidPullToRefresh(
          showChildOpacityTransition: false,
          color: theme.colors.primary,
          backgroundColor: Colors.white,
          onRefresh: () async {
            ref.read(timeTableService).session.clearManagerCache();
            ref.read(timeTableService).getTimeTable(weekCounter: _timeTableService.weekCounter);
          },
          child: HookConsumer(
            builder: (context, ref, child) {
              final _timeTable = ref.watch(timeTableService).timeTable;
              final _phaseTimeTable = ref.watch(timeTableService).phaseTimeTable;

              return Container(
                color: theme.colors.background,
                child: (_timeTable == null)
                    ? Center(
                        child: CircularProgressIndicator(
                          color: theme.colors.progressIndicator,
                        ),
                      )
                    : (ref.watch(timeTableService).isSchool)
                        ? ListView(
                            children: [
                              GridView.count(
                                crossAxisCount: 6,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: buildFirstTimeTableRow(_timeTable, theme),
                              ),
                              GridView.count(
                                crossAxisCount: 6,
                                crossAxisSpacing: 0,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                childAspectRatio: 0.75,
                                children: buildTimeTable(_timeTable, _phaseTimeTable, theme, context),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              GridView.count(
                                crossAxisCount: 6,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: buildFirstTimeTableRow(_timeTable, theme),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                                  child: Text(
                                    "Keine Schulwoche",
                                    style: TextStyle(color: theme.colors.textBackground, fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
              );
            },
          ),
        ),
      ),
    );
  }
}
