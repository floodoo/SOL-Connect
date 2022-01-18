/*Author Philipp Gersch */

import 'package:untis_phasierung/core/api/models/timetable.hour.dart';
import 'package:untis_phasierung/core/api/models/utils.dart';

class TimeTableDay {
  final DateTime _date;

  final _lessonTimes = <String>["800", "845", "945", "1030", "1130", "1215", "1330", "1415", "1515", "1600"];
  final int minHoursPerDay = 10;

  ///Jeder Tag hat 8 Tage fest.
  final _hours = <TimeTableHour>[];
  String _dayName = "";
  String _shortDayName = "";
  String _formattedDay = "";
  String _formattedMonth = "";

  int daysSinceEpoch = 0;
  bool outOfScope = false;

  int xIndex = -1;

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

    daysSinceEpoch = Utils().daysSinceEpoch(_date.millisecondsSinceEpoch);

    for (int i = 0; i < minHoursPerDay; i++) {
      TimeTableHour t = TimeTableHour(null);
      t.startAsString = _lessonTimes[i];
      _hours.add(TimeTableHour(null)); //Leere Stunden
    }

    String date = Utils().convertToUntisDate(_date);
    _formattedDay = date.substring(6);
    _formattedMonth = date.substring(4, 6);
  }

  ///Ob der Tag an einem Wochenende oder in den Ferien liegt
  bool isHolidayOrWeekend() {
    return outOfScope;
  }

  DateTime getDate() {
    return _date;
  }

  String getFormattedDate() {
    return _formattedDay + "." + _formattedMonth;
  }

  ///Gibt eine Liste der Stunden dieses Tages zurück. Diese Liste hat IMMER die Länge 10.
  ///Das bedeutet, Stunden, bei denen kein Unterricht ist haben den Wert isEmpty() auf true
  List<TimeTableHour> getHours() {
    return _hours;
  }

  ///Der Name des Tages. Z.B. Montag, Donnerstag oder Sonntag
  String getDayName() {
    return _dayName;
  }

  ///Der Name des Tages in Kurzform. Z.B. Mo, Do, oder So
  String getShortName() {
    return _shortDayName;
  }

  //Fügt eine Stunde in die Liste ein. Wenn eine Stunde auf eine andere fällt und der Code IRREGULAR ist, wird sie der anderen hinzugefügt.
  void insertHour(dynamic data) {
    TimeTableHour constructed = TimeTableHour(data);

    for (int i = 0; i < _hours.length; i++) {
      if (constructed.startAsString == _lessonTimes[i]) {
        if (_hours[i].getLessonCode() == Codes.empty) {
          _hours[i] = constructed;
        } else {
          _hours[i].addIrregularHour(constructed);
        }
        break;
      }
    }
  }
}
