import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/api/models/timetable.day.dart';
import 'package:untis_phasierung/core/service/services.dart';

class CustomTimeTableDayCard extends ConsumerWidget {
  const CustomTimeTableDayCard({required this.timeTableDay, this.cardColor, Key? key}) : super(key: key);
  final TimeTableDay timeTableDay;
  final Color? cardColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: (cardColor ?? theme.colors.primary),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeTableDay.getShortName(),
              style: TextStyle(color: theme.colors.text),
            ),
            Text(
              timeTableDay.getFormattedDate(),
              //timeTableDay.getDate().day.toString() + "." + timeTableDay.getDate().month.toString(),
              style: TextStyle(color: theme.colors.text),
            ),
          ],
        ),
      ),
    );
  }
}
