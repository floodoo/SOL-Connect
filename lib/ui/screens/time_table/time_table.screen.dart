import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/core/excel/models/mergedtimetable.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_day_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_info_card.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/custom_time_table_hour_card.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';
import 'package:untis_phasierung/ui/themes/app_theme.dart';

class TimeTableScreen extends ConsumerWidget {
  const TimeTableScreen({Key? key}) : super(key: key);
  static final routeName = (TimeTableScreen).toString();

  buildFirstTimeTableRow(TimeTableRange _timeTable, AppTheme theme) {
    List<Widget> timeTableList = [];
    for (int i = 0; i <= 5; i++) {
      if (i == 0) {
        timeTableList.add(
          CustomTimeTableCard(
            child: Icon(
              Icons.calendar_today_rounded,
              color: theme.colors.icon,
            ),
            color: theme.colors.primary,
          ),
        );

        // The first row
      } else {
        timeTableList.add(
          CustomTimeTableDayCard(timeTableDay: _timeTable.getDays()[i - 1]),
        );
      }
    }
    return timeTableList;
  }

  buildTimeTable(TimeTableRange _timeTable, MergedTimeTable? _phasedTimeTable, AppTheme theme, BuildContext context) {
    List<Widget> timeTableList = [];
    int timeColumnCounter = 0;
    int schoolDayCounter = 0;
    List hourList = [6, 12, 18, 24, 30, 36, 42, 48];

    for (int i = 6; i < 54; i++) {
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

      // left column with hours
      if (hourList.contains(i)) {
        timeTableList.add(
          CustomTimeTableHourCard(
            timeTableHour: _timeTable.getDays()[0].getHours()[timeColumnCounter - 1],
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
        timeTableList.add(CustomTimeTableCard(color: theme.colors.phaseUnknown));

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
    final _timeTableService = ref.read(timeTableService);
    final _timeTable = ref.watch(timeTableService).timeTable;
    final _phaseTimeTable = ref.watch(timeTableService).phaseTimeTable;
    final theme = ref.watch(themeService).theme;
    GlobalKey previewContainer = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: Text("Timetable", style: TextStyle(color: theme.colors.text)),
        iconTheme: IconThemeData(color: theme.colors.icon),
        backgroundColor: theme.colors.primary,
        actions: [
          IconButton(
            icon: Icon(
              Icons.adaptive.share_rounded,
              color: theme.colors.icon,
            ),
            onPressed: () {
              ShareFilesAndScreenshotWidgets().shareScreenshot(
                previewContainer,
                MediaQuery.of(context).devicePixelRatio.toInt() * 10000,
                "TimeTable",
                "TimeTable.png",
                "image/png",
                text: "Shared via Untis Phasierung",
              );
            },
          )
        ],
      ),
      drawer: const CustomDrawer(),
      body: GestureDetector(
        onHorizontalDragEnd: (dragEndDetails) {
          if (dragEndDetails.primaryVelocity! < 0) {
            // Page forwards
            _timeTableService.resetTimeTable();
            _timeTableService.getTimeTableNextWeek();
          } else if (dragEndDetails.primaryVelocity! > 0) {
            // Page backwards
            _timeTableService.resetTimeTable();
            _timeTableService.getTimeTablePreviousWeek();
          }
        },
        child: RepaintBoundary(
          key: previewContainer,
          child: Container(
            color: theme.colors.background,
            child: (_timeTable == null)
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colors.icon,
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
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            childAspectRatio: 0.6,
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
                            child: Text(
                              "No school this week",
                              style: TextStyle(color: theme.colors.textBackground, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
