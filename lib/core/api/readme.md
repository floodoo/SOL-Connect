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

```
Montag
	08:00 - 08:45 BBU_Inf 
	08:45 - 09:30 BBU_Inf 
	09:45 - 10:30 BBU_Inf 
	10:30 - 11:15 BBU_Inf 
	11:30 - 12:15 SkWil 
	12:15 - 13:00 SkWil 
	13:30 - 14:15 SkWil [cancelled]
	14:15 - 15:00 SkWil [cancelled]
Dienstag
	08:00 - 08:45 Dkom [cancelled]
	08:45 - 09:30 Dkom 
	09:45 - 10:30 Dkom [irregular]
	09:45 - 10:30 BBU_Wi [cancelled]
	10:30 - 11:15 BBU_Wi 
	11:30 - 12:15 SkWil 
	12:15 - 13:00 SkWil 
	13:30 - 14:15 BBU_Inf 
	14:15 - 15:00 BBU_Inf 
Mittwoch
	08:00 - 08:45 BBU_Inf 
	08:45 - 09:30 BBU_Inf 
	09:45 - 10:30 BBU_Inf 
	10:30 - 11:15 BBU_Inf 
	11:30 - 12:15 ReEv 
	12:15 - 13:00 ReEv 
```
