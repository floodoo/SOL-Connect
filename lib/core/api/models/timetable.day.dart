import 'timetable.hour.dart';
import 'utils.dart' as utils;

class TimeTableDay {
  DateTime _date;
  var _hours = <TimeTableHour>[];
  String _dayName = "";

  int daysSinceEpoch = 0;
  bool outOfScope = false;

  TimeTableDay(this._date) {
    switch (_date.weekday) {
      case 1:
        _dayName = "Montag";
        break;
      case 2:
        _dayName = "Dienstag";
        break;
      case 3:
        _dayName = "Mittwoch";
        break;
      case 4:
        _dayName = "Donnerstag";
        break;
      case 5:
        _dayName = "Freitag";
        break;
      case 6:
        _dayName = "Samstag";
        break;
      case 7:
        _dayName = "Sonntag";
        break;
      default:
        "";
    }

    daysSinceEpoch = utils.daysSinceEpoch(_date.millisecondsSinceEpoch);
  }

  ///Ob der Tag an einem Wochenende oder in den Ferien liegt
  bool isHolidayOrWeekend() {
    return outOfScope;
  }

  DateTime getDate() {
    return _date;
  }

  List<TimeTableHour> getHours() {
    return _hours;
  }

  String getDayName() {
    return _dayName;
  }

  void addHour(dynamic data) {
    _hours.add(new TimeTableHour(data));

    _hours.sort((a, b) => a.end.hour.compareTo(b.end.hour));
  }
}
