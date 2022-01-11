import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/excel/validator.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/arguments/time_table_detail.argument.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/widgets/custom_text.dart';

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
        child: Center(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: CustomText(text: _timeTableHour.getSubject().longName),
              ),
              CustomText(text: _timeTableHour.getActivityType()),
              CustomText(text: "Raum " + _timeTableHour.getRoom().name),
              CustomText(text: _timeTableHour.getLessonCode().name),
              CustomText(text: _timeTableHour.getTitle()),
              if (phase != null) CustomText(text: phase.getFirstHalf().toString()),
              if (phase != null) CustomText(text: phase.getSecondHalf().toString()),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 5,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      fillColor: theme.colors.primary,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      hintText: (_timeTableHour.getLessionInformation() != "")
                          ? _timeTableHour.getLessionInformation()
                          : "If available: additional lesson information",
                      hintStyle: TextStyle(color: theme.colors.text),
                    ),
                    maxLines: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
