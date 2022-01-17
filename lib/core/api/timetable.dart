/*Author Philipp Gersch */

import 'rpcresponse.dart';
import 'models/timetable.day.dart';
import 'models/utils.dart' as utils;
import 'models/timetable.hour.dart';
import 'usersession.dart';

///Diese Klasse wandelt die Antwort in ein TimeTable Objekt um
class TimeTableRange {
  RPCResponse response;
  final DateTime _startDate;
  final DateTime _endDate;

  final _days = <TimeTableDay>[];

  //Welche Woche im aktuellen Block ist das? Startet bei 0
  //Wird erst gesetzt wenn es wirklich gebraucht wird und "getCurrentBlockWeek()" aufgerufen wird.
  int _blockIndex = -1;
  DateTime? _blockStartDate; //Block startdatum dem die timetable woche gehört
  DateTime? _blockEndDate; //Block enddatum dem die timetable woche gehört
  bool _isEmpty = true;

  //TODO wird bis jetzt nur in `UserSession.getRelativeTimeTableForWeek()` gesetzt
  int relativeToCurrent = 0;

  final UserSession _boundUser;

  TimeTableRange(this._startDate, this._endDate, this._boundUser, this.response) {
    //Konstruiere die Tage
    if (response.isError()) {
      if (response.getErrorCode() == -7004) {
        //"no allowed date"
        //erzeuge eine leere Tabelle
        for (int i = 0; i < _endDate.difference(_startDate).inDays; i++) {
          TimeTableDay day = TimeTableDay(_startDate.add(Duration(days: i)));
          _days.add(day);
        }
        return;
      } else {
        throw Exception("Ein Fehler ist bei der Beschaffung des Stundenplanes aufgetreten: " +
            response.getErrorMessage() +
            "(" +
            response.getErrorCode().toString() +
            ")");
      }
    }

    outer:
    for (dynamic entry in response.getPayloadData()) {
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
          _isEmpty = false;
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

  void setManualBlockBounds() {}

  ///Gibt den ersten Montag nach ende des Blockes zurück
  Future<DateTime> getNextBlockEndDate(int relativeToCurrent) async {
    if (_blockEndDate != null) {
      return _blockEndDate!;
    }

    if (_blockStartDate == null) {
      await getNextBlockStartDate(relativeToCurrent);
    }
    //Gehe Wochen nach vorne bis eine leere Woche kommt!
    for (int i = relativeToCurrent; i < relativeToCurrent + 8; i++) {
      TimeTableRange week = await _boundUser.getRelativeTimeTableWeek(i);
      
      if(!week.isNonSchoolblockWeek()) {
        blockWeeks.add(week);
      }

      if (week.isNonSchoolblockWeek() &&
          week.getDays()[0].getDate().millisecondsSinceEpoch > _blockStartDate!.millisecondsSinceEpoch) {
        _blockEndDate = week.getDays()[0].getDate(); //Der erste Montag nach dem Block
        break;
      }
    }
    return _blockEndDate!;
  }

  var blockWeeks = <TimeTableRange>[];

  Future<List<TimeTableRange>> getNextBlockWeeks(int relativeToCurrent) async {
    if(_blockEndDate == null) {
      await getNextBlockEndDate(relativeToCurrent);
    }
    return blockWeeks;
  }

  Future<DateTime> getNextBlockStartDate(int relativeToCurrent) async {
    if (_blockStartDate != null) {
      return _blockStartDate!;
    }

    if (_blockIndex == -1) {
      //Man kommt um eine Abfrage nicht herum
      await getCurrentBlockWeek(relativeToCurrent); //Das AKTUELLE DATUM!
    }
    if (!isNonSchoolblockWeek()) {
      if (_blockIndex == 0) {
        _blockStartDate = getDays()[0].getDate();
        return _blockStartDate!;
      } else if (_blockIndex >= 0) {
        _blockStartDate = _boundUser.getRelativeWeekStartDate(-_blockIndex);
        return _blockStartDate!;
      }
    } else {
      //Suche in der Zukunft
      for (int i = relativeToCurrent; i < relativeToCurrent + 5; i++) {
        TimeTableRange week = await _boundUser.getRelativeTimeTableWeek(i);
        if (!week.isNonSchoolblockWeek()) {
          _blockStartDate = week.getDays()[0].getDate();
          break;
        }
      }
    }
    return _blockStartDate!;
  }

  ///Gibt den index zurück, in welcher Woche die Aktuelle range ist seitdem der neue Block gestartet ist.
  ///Schwere operation. Es wird empfolen diese Funktion nur aufzurufen wenn es wirklich sein muss
  Future<int> getCurrentBlockWeek(int relative) async {
    if (_blockIndex >= 0) return _blockIndex;

    //MAXIMAL 5 Wochen zurück
    int steps = -1;
    for (int i = relative; i >= -5; i--, steps++) {
      TimeTableRange week = await _boundUser.getRelativeTimeTableWeek(i);
      if (week.isNonSchoolblockWeek()) {
        _blockIndex = steps;
        return _blockIndex;
      }
    }
    _blockIndex = -1;
    return _blockIndex;
  }
}
