import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/service/services.dart';

class CustomTimeTableHourCard extends ConsumerWidget {
  const CustomTimeTableHourCard({required this.timeTableHour, this.customColor, Key? key}) : super(key: key);

  final TimeTableHour timeTableHour;
  final Color? customColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    int hour = timeTableHour.yIndex + 1;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: customColor ?? theme.colors.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: AutoSizeText(
                  timeTableHour.getStartTimeString(),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: TextStyle(color: theme.colors.text),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  hour.toString(),
                  style: TextStyle(color: theme.colors.text),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  timeTableHour.getEndTimeString(),
                  style: TextStyle(color: theme.colors.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
