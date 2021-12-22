import 'timetable.hour.dart';
import 'utils.dart' as utils;

class TimeTableDay {
  final DateTime _date;

  ///Jeder Tag hat 8 Tage fest.
  final _hours = <TimeTableHour>[];
  String _dayName = "";
  String _shortDayName = "";

  int daysSinceEpoch = 0;
  bool outOfScope = false;

  TimeTableDay(this._date) {
    switch (_date.weekday) {
      case 1:
        _dayName = "Montag";
        _shortDayName = "Mo";
        break;
      case 2:
        _dayName = "Dienstag";
        _shortDayName = "Di";
        break;
      case 3:
        _dayName = "Mittwoch";
        _shortDayName = "Mi";
        break;
      case 4:
        _dayName = "Donnerstag";
        _shortDayName = "Do";
        break;
      case 5:
        _dayName = "Freitag";
        _shortDayName = "Fr";
        break;
      case 6:
        _dayName = "Samstag";
        _shortDayName = "Sa";
        break;
      case 7:
        _dayName = "Sonntag";
        _shortDayName = "So";
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

  String getShortName() {
    return _shortDayName;
  }

  void insertHour(dynamic data) {
    _hours.add(TimeTableHour(data));

    _hours.sort((a, b) => a.end.hour.compareTo(b.end.hour));
  }
}
