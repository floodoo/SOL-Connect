import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/excel/validator.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/time_table_detail.argument.dart';

class TimeTableDetailScreen extends ConsumerWidget {
  const TimeTableDetailScreen({Key? key}) : super(key: key);
  static final routeName = (TimeTableDetailScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    GlobalKey previewContainer = GlobalKey();
    final TimeTableDetailArgument args = ModalRoute.of(context)!.settings.arguments as TimeTableDetailArgument;
    final MappedPhase? phase = args.phase;
    late TimeTableHour _timeTableHour;

    if (args.timeTableHour.isIrregular()) {
      _timeTableHour = args.timeTableHour.getReplacement();
    } else {
      _timeTableHour = args.timeTableHour;
    }

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
                "TimeTableDetail",
                "TimeTableDetail.png",
                "image/png",
                text: "Shared via Untis Phasierung",
              );
            },
          )
        ],
      ),
      body: RepaintBoundary(
        key: previewContainer,
        child: ListView(
          children: [
            Text(
              _timeTableHour.getSubject().longName,
              style: TextStyle(color: theme.colors.textBackground),
            ),
            Text(
              _timeTableHour.getActivityType(),
              style: TextStyle(color: theme.colors.textBackground),
            ),
            Text(
              _timeTableHour.getTeacher().longName,
              style: TextStyle(color: theme.colors.textBackground),
            ),
            Text(
              _timeTableHour.getRoom().longName,
              style: TextStyle(color: theme.colors.textBackground),
            ),
            Text(
              _timeTableHour.getLessonCode().name,
              style: TextStyle(color: theme.colors.textBackground),
            ),
            Text(
              _timeTableHour.getTitle(),
              style: TextStyle(color: theme.colors.textBackground),
            ),
            Text(
              _timeTableHour.getLessionInformation(),
              style: TextStyle(color: theme.colors.textBackground),
            ),
          ],
        ),
      ),
    );
  }
}
