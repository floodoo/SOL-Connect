import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/api/models/timetable.day.dart';
import 'package:sol_connect/core/service/services.dart';

class CustomTimeTableDayCard extends ConsumerWidget {
  const CustomTimeTableDayCard({required this.timeTableDay, this.cardColor, Key? key}) : super(key: key);

  final TimeTableDay timeTableDay;
  final Color? cardColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      color: (cardColor ?? theme.colors.primary),
      margin: const EdgeInsets.all(2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timeTableDay.getShortName(), style: TextStyle(color: theme.colors.textInverted)),
            Text(timeTableDay.getFormattedDate(), style: TextStyle(color: theme.colors.textInverted)),
          ],
        ),
      ),
    );
  }
}
