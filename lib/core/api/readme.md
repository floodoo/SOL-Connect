# API Wrapper Dokumentation

## Eine Session erstellen

Eine Session wird mit dem Objekt `UserSession` erstellt:
```dart
import 'lib/core/api/usersession.dart';
UserSession session = new UserSession("schul-id", "app-name");
session.createSession("USERNAME", "PASSWORT").then((s) {});
```
Der App Name ist beliebig, die Schul-ID ist die ID der Schule. Z.B. "bbs1-mainz"<br>
Eine Session wird erstellt und als gültig markiert, wenn man sich mit der Funktion `createSession(String userName, String passWord)` erfolgreich angemeldet hat<br>
Falls beim Anmeldeprozess ein Fehler auftritt, wird eine Exception geworfen.

## Stundenpläne Abfragen

Um einen Stundenplan abzufragen benötigt man ein gültiges Session Objekt, ansonsten wird eine Exception geworfen.
Folgende Funktionen können verwendet werden um einen Stundenplan abzufragen:

```dart
session.getTimeTable(DateTime from, DateTime to);
session.getTimeTableForToday();
session.getTimeTableForThisWeek();
```
Ich denke mal die Namen sind schlüssig.
Alle Funktionen liefern das Objekt `TimeTableRange` zurück. Es strukturier und sortiert automatisch alle zurückgegebenen Tage fortlaufend.
Alle Tage sind in einem Array `days` gespeichert.

Dieses Array besteht aus einer Liste von Objekten vom Typ `TimeTableDay`
Jeder TimeTable Tag besitzt eine Liste von Stunden vom Typ `TimeTableHour`
Alle Stunden sind chronologisch sortiert. `TimeTableDay.dayName` behinhaltet den Namen des Wochentages auf Deutsch.

## Wochenende und Ferientage
Wochenenden und Ferientage werden von der API einfach weggelassen, jedoch fügt der Wrapper diese automatisch hinzu, dass zwischen dem gewollten Start Datum und End Datum keine Lücken entstehen.<br>
Es ist also gewährleistet, dass alle Tage zwischen zwei angegebenen TimeTable Daten lückenlos in der erzeugten Liste vorhanden sind.
Diese Tage besitzten keine Stundeneinträge und besitzen den Wert `outOfScope = true` 

# Beispiel
Beispiel für eine Stundenplanabfrage.:
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
## Ausgabe:

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
