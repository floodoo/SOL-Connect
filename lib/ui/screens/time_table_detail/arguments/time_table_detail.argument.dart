import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/excel/validator.dart';

class TimeTableDetailArgument {
  final TimeTableHour timeTableHour;
  final MappedPhase? phase;

  TimeTableDetailArgument({required this.timeTableHour, this.phase});
}
