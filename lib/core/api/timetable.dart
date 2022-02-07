/*Author Philipp Gersch */
import 'package:sol_connect/core/api/models/timetable.day.dart';
import 'package:sol_connect/core/api/models/timetable.hour.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/rpcresponse.dart';
import 'package:sol_connect/core/api/timetable_manager.dart';

///Diese Klasse wandelt die Antwort in ein TimeTable Objekt um
class TimeTableRange {
  RPCResponse response;
  final DateTime _startDate;
  final DateTime _endDate;

  final _days = <TimeTableDay>[];

  bool _isEmpty = true;

  final TimetableFrame _boundFrame;
  int _schoolhoursLength = TimeTableDay.minHoursPerDay;

  TimeTableRange(this._startDate, this._endDate, this._boundFrame, this.response) {
    //Konstruiere die Tage
    if (response.isError) {
      if (response.rpcResponseCode == -7004) {
        //"no allowed date"
        //erzeuge eine leere Tabelle
        for (int i = 0; i < _endDate.difference(_startDate).inDays; i++) {
          TimeTableDay day = TimeTableDay(_startDate.add(Duration(days: i)), this);
          _days.add(day);
        }
        return;
      } else {
        throw Exception("Ein Fehler ist bei der Beschaffung des Stundenplanes aufgetreten: " +
            response.errorMessage +
            "(" +
            response.rpcResponseCode.toString() +
            ")");
      }
    }
    //Das "echte" Startdatum. Stundenpläne an sich haben ein festes Datum. Diese können jedoch durch _startDate beeinflusst werden.
    DateTime? realStartDate;

    outer:
    for (dynamic entry in response.payloadData) {
      DateTime current = Utils.convertToDateTime(entry['date'].toString());
      //Checke ob der Tag schon erstellt wurde

      for (TimeTableDay day in _days) {
        if (day.getDate().day == current.day) {
          //Wenn ja, füge die Stunde in den Tag
          day.insertHour(entry);
          if (Utils.dayGreaterOrEqual(realStartDate!, current)) {
            realStartDate = current;
          }

          continue outer;
        }
      }
      //Ansonsten erstelle einen neuen Tag mit der Stunde!
      TimeTableDay day = TimeTableDay(current, this);
      day.insertHour(entry);
      _days.add(day);

      realStartDate ??= current;
      if (Utils.dayGreaterOrEqual(realStartDate, current)) {
        realStartDate = current;
      }
    }

    //Das "echte" Startdatum. Wie es in der timetable drin ist
    realStartDate ??= _startDate;

    if (_boundFrame.getManager().userSession.isDemoSession) {
      int realStartDateDays = Utils.daysSinceEpoch(realStartDate.millisecondsSinceEpoch);
      //Jetzt "normalisiere" alle Daten (Pl. von Datum) (Verschiebe das Datum in das angegebene Startdatum)
      for (TimeTableDay day in _days) {
        int weekdayIndex = Utils.daysSinceEpoch(day.getDate().millisecondsSinceEpoch) - realStartDateDays;
        day.modifyDate(_startDate.add(Duration(days: weekdayIndex)));
      }
    }

    var finalList = <TimeTableDay>[];

    int day1 = Utils.daysSinceEpoch(DateTime(_startDate.year, _startDate.month, _startDate.day).millisecondsSinceEpoch);
    int diff = _endDate.difference(_startDate).inDays;
    if (diff < 0) throw Exception("Das Start Datum muss größer als das Enddatum sein!");

    main:
    for (int i = 0; i < diff; i++) {
      for (TimeTableDay d in _days) {
        if (d.getHours().length > _schoolhoursLength) {
          _schoolhoursLength = d.getHours().length;
        }

        if (d.daysSinceEpoch - day1 == i) {
          _isEmpty = false;
          finalList.add(d);
          _days.remove(d);
          continue main;
        }
      }
      //Nicht gefunden.
      TimeTableDay outOfScope = TimeTableDay(_startDate.add(Duration(days: i)), this);
      outOfScope.outOfScope = true;
      finalList.add(outOfScope);
    }

    _days.clear();
    _days.addAll(finalList);

    //Setze die Stundenkoordinaten und das Datum endgültig
    for (int i = 0; i < _days.length; i++) {
      _days[i].xIndex = i;

      for (int j = 0; j < schoolDayLength; j++) {
        if (j >= _days[i].getHours().length) {
          TimeTableHour empty = TimeTableHour(null, this);
          empty.setYIndex(yIndex: j);
          empty.xIndex = _days[i].xIndex;
          _days[i].appendHour(empty); //Da sortiert, füge diese Stunde am ende an
        } else {
          _days[i].getHours()[j].xIndex = _days[i].xIndex;
          _days[i].getHours()[j].setYIndex(yIndex: j);
        }
      }
    }
  }

  int get schoolDayLength => _schoolhoursLength;

  DateTime getStartDate() {
    return _startDate;
  }

  DateTime getEndDate() {
    return _endDate;
  }

  ///Wenn man sich die Timetable als 2d Grid vorstellt, kann man hier die Stunden bekommen die einem solchem Grid entsprechen
  ///
  ///Das Grid ist ___`getDays().length * 10`___ Felder groß
  ///
  ///* `xIndex = 0, yIndex = 0` wäre Montag erste Stunde
  ///* `xIndex = 1, yIndex = 2` wäre Dienstag 3. Stunde
  TimeTableHour getHourByIndex({int xIndex = 0, int yIndex = 0}) {
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

  ///Gibt true zurück, wenn diese Range nicht in einem Schulblock liegt.
  bool isNonSchoolblockWeek() {
    return _isEmpty;
  }

  ///Gibt das Startdatum im Format dd.mm zurück
  String getStartDateString() {
    return (_startDate.day < 10 ? "0" + _startDate.day.toString() : _startDate.day.toString()) +
        "." +
        (_startDate.month < 10 ? "0" + _startDate.toString() : _startDate.month.toString());
  }

  ///Gibt das Enddatum im Format dd.mm zurück
  String getEndDateString() {
    return (_endDate.day < 10 ? "0" + _endDate.day.toString() : _endDate.day.toString()) +
        "." +
        (_endDate.month < 10 ? "0" + _endDate.month.toString() : _endDate.month.toString());
  }

  ///Über den Frame bekommt man zugriff auf Blockdaten, wochenindex etc.
  TimetableFrame getBoundFrame() {
    return _boundFrame;
  }
}
