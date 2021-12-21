Beispiel für eine Stundenplanabfrage:
```dart
import 'usersession.dart';
import 'timetable.day.dart';
import 'timetable.hour.dart';

void main() {
  //Dieses Beispiel gibt den Stundenplan vom 19.12 bis 23.12 mit Uhrzeit und Fach. Wenn ein Fach ausfällt oder sonstiges steht der Code hinter dem Fach
  //Ich werden in Zukunft noch ein Enum für die codes erstellen

  UserSession gw = new UserSession("bbs1-mainz", "testAPP");

  //Session mit Login Daten erstellen
  gw.createSession("USERNAME", "PASSWORD").then((e) {
    //Stundenplan vom 19.12 bis 23.12 abfragen
    gw.getTimeTable(DateTime.parse("20211219"), DateTime.parse("20211223")).then((value) {
     
      for (TimeTableDay day in value.days) {
        print(day.dayName);
        for (TimeTableHour hour in day.hours) {
          print("\t" +
              hour.getTitle() +
              " " +
              hour.subject.name +
              " " +
              (hour.code != "regular" ? "[" + hour.code + "]" : ""));
        }
      }

    });
  });
}
```
