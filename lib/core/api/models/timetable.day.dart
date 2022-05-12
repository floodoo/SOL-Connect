/*Author Philipp Gersch */
import 'package:sol_connect/core/api/models/timetable.hour.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/timetable.dart';

class TimeTableDay {
  DateTime _date;

  //Wie viele Stunden mindestens in einen Stundenplan geladen werden sollen, wenn er leer ist
  static const int minHoursPerDay = 8;

  ///Jeder Tag hat (MINIMAL) 10 Stunden fest.
  final _hours = <TimeTableHour>[];
  String _dayName = "";
  String _shortDayName = "";
  String _formattedDay = "";
  String _formattedMonth = "";

  int daysSinceEpoch = 0;
  bool outOfScope = false;

  int xIndex = -1;

  final TimeTableRange _rng;

  TimeTableDay(this._date, this._rng) {
    switch (_date.weekday) {
      case 1:
        _dayName = "Montag";
        _shortDayName = "Mo.";
        break;
      case 2:
        _dayName = "Dienstag";
        _shortDayName = "Di.";
        break;
      case 3:
        _dayName = "Mittwoch";
        _shortDayName = "Mi.";
        break;
      case 4:
        _dayName = "Donnerstag";
        _shortDayName = "Do.";
        break;
      case 5:
        _dayName = "Freitag";
        _shortDayName = "Fr.";
        break;
      case 6:
        _dayName = "Samstag";
        _shortDayName = "Sa.";
        break;
      case 7:
        _dayName = "Sonntag";
        _shortDayName = "So.";
        break;
      default:
        "";
    }

    for (int i = 0; i < minHoursPerDay; i++) {
      TimeTableHour t = TimeTableHour(null, _rng);
      t.startAsString = _rng.getBoundFrame().getManager().timegrid.getEntryByYIndex(yIndex: i).startTime;
      _hours.add(TimeTableHour(null, _rng)); //Leere Stunden
    }

    modifyDate(_date);
  }

  void modifyDate(DateTime newDate) {
    _date = newDate;

    String date = Utils.convertToUntisDate(_date);
    _formattedDay = date.substring(6);
    _formattedMonth = date.substring(4, 6);

    daysSinceEpoch = Utils.daysSinceEpoch(_date.millisecondsSinceEpoch);
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

  ///Gibt eine Liste der Stunden dieses Tages zurück. Diese Liste hat minimal die Länge 10.
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

  void appendHour(TimeTableHour hour) {
    _hours.add(hour);
  }

  //Fügt eine Stunde in die Liste ein. Wenn eine Stunde auf eine andere fällt und der Code IRREGULAR ist, wird sie der anderen hinzugefügt.
  void insertHour(dynamic data) {
    TimeTableHour constructed = TimeTableHour(data, _rng);

    if (constructed.hourIndex < _hours.length) {
      for (int i = 0; i < _hours.length; i++) {
        if (constructed.startAsString ==
            _rng.getBoundFrame().getManager().timegrid.getEntryByYIndex(yIndex: i).startTime) {
          if (_hours[i].lessonCode == Codes.empty) {
            _hours[i] = constructed;
          } else {
            _hours[i].addIrregularHour(constructed);
          }
          break;
        }
      }
    } else {
      //Ansonsten erweitere den Stundenplan gemäß dem Index
      int diffToMax = (constructed.hourIndex + 1) - minHoursPerDay;

      for (int i = 0; i < minHoursPerDay + diffToMax; i++) {
        if (i >= _hours.length && i != constructed.hourIndex) {
          _hours.add(TimeTableHour(null, _rng));
        }
        if (constructed.hourIndex == i) {
          _hours.add(constructed);
          break;
        }
      }
    }
  }
}
