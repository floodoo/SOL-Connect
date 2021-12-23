import 'rpcresponse.dart';
import 'models/timetable.day.dart';
import 'models/utils.dart' as utils;
import 'models/timetable.hour.dart';

///Diese Klasse wandelt die Antwort in ein TimeTable Objekt um
class TimeTableRange {
  RPCResponse response;
  final DateTime _startDate;
  final DateTime _endDate;

  final _days = <TimeTableDay>[];

  TimeTableRange(this._startDate, this._endDate, this.response) {
    //Konstruiere die Tage
    if (response.isError()) {
      throw Exception("Ein Fehler ist bei der Beschaffung des Stundenplanes aufgetreten: " +
          response.errorMessage +
          "(" +
          response.errorCode.toString() +
          ")");
    }

    outer:
    for (dynamic entry in response.payload) {
      DateTime current = utils.convertToDateTime(entry['date'].toString());
      //Checke ob der Tag schon erstellt wurde
      for (TimeTableDay day in _days) {
        if (day.getDate().day == current.day) {
          //Wenn ja, füge die Stunde in den Tag
          day.insertHour(entry);
          continue outer;
        }
      }
      //Ansonsten erstelle einen neuen Tag mit der Stunde!
      TimeTableDay day = TimeTableDay(current);
      day.insertHour(entry);
      _days.add(day);
    }

    var finalList = <TimeTableDay>[];
    int day1 = utils.daysSinceEpoch(DateTime(_startDate.year, _startDate.month, _startDate.day).millisecondsSinceEpoch);

    int diff = _endDate.difference(_startDate).inDays;
    if (diff < 0) throw Exception("Das Start Datum muss größer als das Enddatum sein!");

    main:
    for (int i = 0; i < diff; i++) {
      for (TimeTableDay d in _days) {
        if (d.daysSinceEpoch - day1 == i) {
          finalList.add(d);
          _days.remove(d);
          continue main;
        }
      }
      //Nicht gefunden.
      TimeTableDay outOfScope = TimeTableDay(_startDate.add(Duration(days: i)));
      outOfScope.outOfScope = true;
      finalList.add(outOfScope);
    }

    _days.clear();
    _days.addAll(finalList);

    //Setze die Stundenkoordinaten
    for (int i = 0; i < _days.length; i++) {
      _days[i].xIndex = i;
      for (int j = 0; j < _days[i].getHours().length; j++) {
        _days[i].getHours()[j].xIndex = _days[i].xIndex;
        _days[i].getHours()[j].yIndex = j;
      }
    }
  }

  ///Wenn man sich die Timetable als 2d Grid vorstellt, kann man hier die Stunden bekommen die einem solchem Grid entsprechen
  ///
  ///Das Grid ist ___`getDays().length * 10`___ Felder groß
  ///
  ///* `xIndex = 0, yIndex = 0` wäre Montag erste Stunde
  ///* `xIndex = 1, yIndex = 2` wäre Dienstag 3. Stunde
  TimeTableHour getHourByIndex(int xIndex, int yIndex) {
    return _days[xIndex].getHours()[yIndex];
  }

  /// Alle vollen Tage die vom Start bis zum Enddatum angefragt wurden.
  /// Wenn Tage außerhalb des scopes liegen (Wochenende oder Ferien) werden diese auch der Liste hinzugefügt,
  /// besitzen jedoch nur leere Stunden. Siehe `timetable.day.dart` -> `getHours()`
  List<TimeTableDay> getDays() {
    return _days;
  }

  ///Gibt einen bestimmten Wochentag zurück.
  ///
  ///[weekday] ist der Name des Wochentages in kurz oder Langform. Z.B. "Montag" oder "Mo". Der Name ist nicht case- sensitive.
  TimeTableDay getDay(String weekday) {
    for (TimeTableDay day in getDays()) {
      if (day.getDayName().toLowerCase() == weekday.toLowerCase() ||
          day.getShortName().toLowerCase() == weekday.toLowerCase()) {
        return day;
      }
    }
    return getDays()[0];
  }
}
