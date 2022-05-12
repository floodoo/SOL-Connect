import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    final timeTableServiceInstance = ref.read(timeTableService);
    final isDebugTimetable = ref.read(timeTableService).session.isDemoSession;
    String title = "Stundenplan";
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      title = arguments['title'];
    }

    List<Widget> buildFirstTimeTableRow(TimeTableRange timeTable, AppTheme theme) {
      List<Widget> timeTableList = [];
      for (int i = 0; i <= 5; i++) {
        // Icon in the top right corner
        if (i == 0) {
          timeTableList.add(
            CustomTimeTableCard(
              color: theme.colors.timetableCardEdge,
              child: Icon(
                Icons.calendar_today_rounded,
                color: theme.colors.textInverted,
              ),
            ),
          );

          // The first row
        } else {
          timeTableList.add(
            CustomTimeTableDayCard(timeTableDay: timeTable.getDays()[i - 1], cardColor: theme.colors.timetableCardEdge),
          );
        }
      }
      return timeTableList;
    }

    List<Widget> buildTimeTable(
      TimeTableRange timeTable,
      MergedTimeTable? phasedTimeTable,
      AppTheme theme,
      BuildContext context,
    ) {
      List<Widget> timeTableList = [];
      int timeColumnCounter = 0;
      int schoolDayCounter = 0;

      for (int i = 6; i < 6 * timeTable.schoolDayLength + 6; i++) {
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
              timeTableHour: timeTable.getDays()[0].getHours()[timeColumnCounter - 1],
              customColor: theme.colors.timetableCardEdge,
            ),
          );

          // If holiday  or weekend
        } else if (timeTable.getDays()[schoolDayCounter].isHolidayOrWeekend()) {
          /*timeTableList.add(
            CustomTimeTableCard(
              child: const Text("Holiday"),
              color: theme.colors.phaseUnknown,
            ),
          );*/
          timeTableList.add(CustomTimeTableCard(color: theme.colors.background));

          // If no subject
        } else if (timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1].isEmpty) {
          timeTableList.add(CustomTimeTableCard(color: theme.colors.background));

          // subject
        } else {
          bool connectBottom = false;
          bool connectTop = false;
          bool doubleLesson = false;
          //bool hourBeforeLunch = false;

          TimeTableHour current = timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1];

          if (timeColumnCounter - 1 > 0) {
            TimeTableHour prev = timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 2];
            if (current.teacher.name == prev.teacher.name &&
                current.subject.longName == prev.subject.longName &&
                current.room.name == prev.room.name &&
                current.getStartTimeString() != "13:30") {
              //Doppelstunde!
              connectTop = true;
              doubleLesson = true;
            }
          }
          if (timeColumnCounter < timeTable.getDays()[schoolDayCounter].getHours().length) {
            TimeTableHour next = timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter];
            if (current.teacher.name == next.teacher.name &&
                current.subject.longName == next.subject.longName &&
                current.room.name == next.room.name) {
              //Doppelstunde!
              connectBottom = true;
            }
            if (current.endTime.hour == 13) {
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
                if (timeTable.getDays()[schoolDayCounter].getHours()[i].teacher.name != current.teacher.name ||
                    timeTable.getDays()[schoolDayCounter].getHours()[i].room.name != current.room.name) {
                  return false;
                }
              }
            } else {
              for (int i = timeColumnCounter - 1; i < index; i++) {
                if (timeTable.getDays()[schoolDayCounter].getHours()[i].teacher.name != current.teacher.name ||
                    timeTable.getDays()[schoolDayCounter].getHours()[i].room.name != current.room.name) {
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
          String subjectDisplay = current.subject.name;
          String teacherDisplay = current.teacher.name;
          String roomDisplay = current.room.name;

          if (current.lessonCode == Codes.cancelled && current.replacements.isNotEmpty) {
            subjectDisplay = current.replacement.subject.name;
            teacherDisplay = current.replacement.teacher.name;
            roomDisplay = current.replacement.room.name;
          }

          for (int i = 0; i < timeTable.schoolDayLength; i++) {
            if (timeTable.getHourByIndex(xIndex: schoolDayCounter, yIndex: i).teacher.name == current.teacher.name &&
                timeTable.getHourByIndex(xIndex: schoolDayCounter, yIndex: i).room.name == current.room.name) {
              if (connectedToCurrent(i)) {
                doubleLessonCount++;
                counter++;
                if (i == timeColumnCounter - 1) {
                  doubleLessonIndex = counter;
                }
              }
            }
          }

          if (current.lessonCode != Codes.irregular) {
            if (doubleLessonCount == 1) {
              lessonInfo = [current.subject.name, current.teacher.name, current.room.name];
            } else if (doubleLessonCount == 2) {
              if (doubleLessonIndex == 0) {
                lessonInfo = [subjectDisplay, teacherDisplay];
              } else {
                lessonInfo = [roomDisplay];
              }
            } else if (doubleLessonCount >= 3) {
              if (doubleLessonIndex == 0) {
                lessonInfo = [subjectDisplay];
              } else if (doubleLessonIndex == 1) {
                lessonInfo = [teacherDisplay];
              } else if (doubleLessonIndex == 2) {
                lessonInfo = [roomDisplay];
              }
            }
          } else {
            lessonInfo = [subjectDisplay, teacherDisplay, roomDisplay];
          }

          if (current.lessonCode == Codes.cancelled && current.replacements.isNotEmpty) {
            current = current.replacement;
          }

          timeTableList.add(
            CustomTimeTableInfoCard(
              timeTableHour: current,
              phase: (phasedTimeTable != null)
                  ? phasedTimeTable
                      .getPhaseForHour(timeTable.getDays()[schoolDayCounter].getHours()[timeColumnCounter - 1])
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
        title: isDebugTimetable
            ? Column(
                children: [
                  Text(title),
                  Text("Debug Session", style: TextStyle(color: Colors.orange.shade600, fontSize: 15)),
                ],
              )
            : Text(title, style: TextStyle(color: theme.colors.text)),
        iconTheme: IconThemeData(color: theme.colors.icon),
        backgroundColor: theme.colors.primary,
        actions: [
          IconButton(
            onPressed: () {
              timeTableServiceInstance.resetWeekCounter();
              timeTableServiceInstance.resetTimeTable();
              timeTableServiceInstance.getTimeTable();
            },
            icon: const Icon(Icons.today),
            tooltip: "Springe zur aktuellen Woche",
          )
        ],
      ),
      drawer: const CustomDrawer(),
      body: LiquidPullToRefresh(
        showChildOpacityTransition: false,
        color: theme.colors.timetableBackground,
        backgroundColor: Colors.white,
        onRefresh: () async {
          ref.read(timeTableService).session.clearManagerCache();
          ref.read(timeTableService).getTimeTable(weekCounter: timeTableServiceInstance.weekCounter);
        },
        child: HookConsumer(
          builder: (context, ref, child) {
            final timeTable = ref.watch(timeTableService).timeTable;
            final phaseTimeTable = ref.watch(timeTableService).phaseTimeTable;
            final timetableLoadingException = ref.watch(timeTableService).timetableLoadingException;

            List<Widget> timeTableList = [];
            List<Widget> firstTimeTableRowList = [];

            if (timeTable != null) {
              firstTimeTableRowList = buildFirstTimeTableRow(timeTable, theme);
              timeTableList = buildTimeTable(
                timeTable,
                phaseTimeTable,
                theme,
                context,
              );
            }

            return GestureDetector(
              onHorizontalDragEnd: (dragEndDetails) {
                if (dragEndDetails.primaryVelocity! < 0 && timeTable != null) {
                  // Next page
                  timeTableServiceInstance.resetTimeTable();
                  timeTableServiceInstance.getTimeTableNextWeek();
                } else if (dragEndDetails.primaryVelocity! > 0 && timeTable != null) {
                  // Previous page
                  timeTableServiceInstance.resetTimeTable();
                  timeTableServiceInstance.getTimeTablePreviousWeek();
                }
              },
              child: Container(
                color: theme.colors.background,
                child: (timeTable == null && timetableLoadingException == null)
                    ? Center(
                        child: CircularProgressIndicator(
                          color: theme.colors.progressIndicator,
                        ),
                      )
                    : (timeTable == null && timetableLoadingException != null)
                        ? Padding(
                            padding: const EdgeInsets.all(30),
                            child: Text(
                                "Ein unbekannter Fehler ist aufgetreten:\n\n$timetableLoadingException\n\nBitte logge dich aus und versuche es erneut",
                                style: TextStyle(color: theme.colors.error, fontSize: 19)))
                        : (ref.watch(timeTableService).isSchool)
                            ? ListView(
                                children: [
                                  AnimationLimiter(
                                    child: GridView.count(
                                      crossAxisCount: 6,
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: List.generate(
                                        firstTimeTableRowList.length,
                                        (int index) {
                                          return AnimationConfiguration.staggeredGrid(
                                            position: index,
                                            duration: const Duration(milliseconds: 220),
                                            columnCount: 6,
                                            child: ScaleAnimation(
                                              child: FadeInAnimation(
                                                child: firstTimeTableRowList[index],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  AnimationLimiter(
                                    child: GridView.count(
                                      crossAxisCount: 6,
                                      crossAxisSpacing: 0,
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      childAspectRatio: 0.75,
                                      children: List.generate(
                                        timeTableList.length,
                                        (int index) {
                                          return AnimationConfiguration.staggeredGrid(
                                            position: index,
                                            duration: const Duration(milliseconds: 220),
                                            columnCount: 6,
                                            child: ScaleAnimation(
                                              child: FadeInAnimation(
                                                child: timeTableList[index],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  AnimationLimiter(
                                    child: GridView.count(
                                      crossAxisCount: 6,
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: List.generate(
                                        firstTimeTableRowList.length,
                                        (int index) {
                                          return AnimationConfiguration.staggeredGrid(
                                            position: index,
                                            duration: const Duration(milliseconds: 220),
                                            columnCount: 6,
                                            child: ScaleAnimation(
                                              child: FadeInAnimation(
                                                child: firstTimeTableRowList[index],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
