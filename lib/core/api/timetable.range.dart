import 'rpcresponse.dart';
import 'timetable.day.dart';
import 'utils.dart';
import 'timetable.hour.dart';

/**Diese Klasse wandelt die Antwort in ein TimeTable Objekt um*/
class TimeTableRange {
  RPCResponse response;

  var days = <TimeTableDay>[];

  TimeTableRange(this.response) {
    this.response = response;

    if (response.payload.runtimeType != List)
      throw Exception("Falsches Datenformat");

    //Konstruiere die Tage
    main:
    for (dynamic entry in response.payload) {
      DateTime current = convertToDateTime(entry['date'].toString());
      //Checke ob der Tag schon erstellt wurde
      for (TimeTableDay day in days) {
        if (day.date.day == current.day) {
          //Wenn ja, füge die Stunde in den Tag
          day.addHour(entry);
          continue main;
        }
      }
      //Ansonsten erstelle einen neuen Tag mit der Stunde!
      TimeTableDay day = new TimeTableDay(current);
      day.addHour(entry);
      days.add(day);
    }

    //Sortiere die Tage nach Datum weil, warum auch immer die nich sortiert sind.
    days.sort((a, b) =>
        a.date.millisecondsSinceEpoch.compareTo(b.date.millisecondsSinceEpoch));

    for (TimeTableDay day in days) {
      print(day.date);
      for (TimeTableHour hour in day.hours) {
        print(hour.getTitle() + " " + hour.subject.longName);
      }
    }
  }
}
