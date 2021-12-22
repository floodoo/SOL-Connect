import 'rpcresponse.dart';
import 'models/timetable.day.dart';
import 'models/utils.dart' as utils;

/**Diese Klasse wandelt die Antwort in ein TimeTable Objekt um*/
class TimeTableRange {
  RPCResponse response;
  DateTime _startDate;
  DateTime _endDate;

  /**Alle vollen Tage die vom Start bis zum Enddatum angefragt wurden.<br>
   * Wenn Tage außerhalb des scopes liegen (Wochenende oder Ferien) werden diese auch der Liste hinzugefügt, 
   * besitzen jedoch keine Stunden*/
  var _days = <TimeTableDay>[];

  TimeTableRange(this._startDate, this._endDate, this.response) {
    this.response = response;

    //Konstruiere die Tage
    main:
    for (dynamic entry in response.payload) {
      DateTime current = utils.convertToDateTime(entry['date'].toString());
      //Checke ob der Tag schon erstellt wurde
      for (TimeTableDay day in _days) {
        if (day.getDate().day == current.day) {
          //Wenn ja, füge die Stunde in den Tag
          day.addHour(entry);
          continue main;
        }
      }
      //Ansonsten erstelle einen neuen Tag mit der Stunde!
      TimeTableDay day = new TimeTableDay(current);
      day.addHour(entry);
      _days.add(day);
    }

    var finalList = <TimeTableDay>[];
    int day1 =
        utils.daysSinceEpoch(new DateTime(_startDate.year, _startDate.month, _startDate.day).millisecondsSinceEpoch);

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
      TimeTableDay outOfScope = new TimeTableDay(_startDate.add(Duration(days: i)));
      outOfScope.outOfScope = true;
      finalList.add(outOfScope);
    }

    _days.clear();
    _days.addAll(finalList);
  }

  ///Gibt die Tage der timetable als timetable.day.dart Liste zurück
  List<TimeTableDay> getDays() {
    return _days;
  }
}
