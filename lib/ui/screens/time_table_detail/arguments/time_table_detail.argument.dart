import 'package:sol_connect/core/api/models/timetable.hour.dart';
import 'package:sol_connect/core/excel/validator.dart';

class TimeTableDetailArgument {
  final TimeTableHour timeTableHour;
  final MappedPhase? phase;

  TimeTableDetailArgument({required this.timeTableHour, this.phase});
}
