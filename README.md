<a href="https://www.freepik.com/photos/background">Background photo created by rawpixel.com - www.freepik.com</a>

# Einbindung der Phasierung

Die Phasierung sollte unabhängig vom Stundenplan und der User Session sein.<br>
Dies hat folgende Vorteile:
- Keine Änderungen an der bestehenden Struktur.
- Der Stundenplan muss nicht auf eine Phasierung zeigen, die vielleicht noch gar nicht verfügbar oder geladen ist.
- Es ist nicht garantiert, dass eine Excel gültig ist.
- Phasierung kann trotzdem einfach in den Stundenplan eingebunden werden.

-> Jegliches Excel handling passiert unabhängig vom der UserSession. Es kann über ein generiertes `MergedTimeTable` Objekt die Phasierung ausgelesen werden.

## Kriterien an die Excel Datei

Das Laden und verifizieren einer Excel Datei ist vollkommen dynamisch und passt sich an das bereits bestehende Format an.

Es muss ein geladener Stundenplan existieren. Dieser wird dann genommen und wie eine "Schablone" über jede Excel Zelle gehalten (Um es einfach auszudrücken)
Wenn die Schablone auf einen Stundenplan in der Excel passt, wird diese gemappt.
Wichtig ist außerdem, dass <b>über</b> dem Excel Stundenplan die Woche des aktuellen Blocks angegeben ist. Z.B. "Woche 1".<br>
Alle kriterien sind mit dem bereits benutzten Format erfüllt.

## Excel Server

Da es nicht möglich ist Zellenfarben auszulesen, wird ein aktive Excel Server benötigt.
Siehe "Excel Server ausführen"

## Laden einer Excel Datei

Das laden und verifizieren wird beides vom Objekt `ExcelValidator` übernommen.
Gefunden in `excel/validator.dart`
Eine Testdatei kann in /assets/excel/model1.xlsx gefunden werden.

```dart
ExcelValidator validator = ExcelValidator("excel-server-adresse", "C:/pfad/zur/excel.xlsx");
```
Um die Phasierung von einem bestimmten Stundenplan, wird die Funktion `mergeExcelWithTimetable(timetable)` benötigt.
Diese Funktion ist asynchron, da die Farben vom Excel Server geladen werden müssen.

```dart
MergedTimeTable merged = await validator.mergeExcelWithTimetable(timetable);
```
>!ACHTUNG!: Bis jetzt darf nur eine TimeTable in `mergeExcelWithTimetable(timetable)` übergeben werden, die durch `UserSession.getRelativeTimeTableWeek(int relative)`
>erzeugt wurde wenn nicht die aktuelle Woche abgefragt werden soll!

## Auslesen einer Stunde

Um eine Phasierung auszulesen stehen vom `MergedTimeTable` Objekt zwei Funktionen zur verfügung:

```dart
MappedPhase phaseFromIndex = merged.getPhaseFromHourIndex(xIndex: 1, yIndex: 3); //<- Das ließe sich übersetzen in "Dienstag", 4. Stunde.
MappedPhase phaseFromHour = merged.getPhaseFromHour(TimeTableHour);
```
Mit der MappedPhase lässt sich nun die erste und zweite hälfte der Stunde auslesen, dazu auch die Phasierungsfarbe.
Dieses Beispiel gibt den Namen und die Farbe der Phase vom Beispiel oben aus:

```dart
print(phaseFromIndex.getFirstHalf().name); -> "reflection"
print(phaseFromIndex.getFirstHalf().color); -> "(r: 255, g: 0, b: 0)"
```
## Error Handling

Falls eine Excel datei nicht verifiziert werden konnte, kann man das im zurückgegebenen `MergedTimeTable` Objekt überprüfen.
Wenn isValid() false zurückliefert, kann eine Fehlernachricht mit `MergedTimeTable.errorMessage` ausgelesen werden.

```dart
if(merged.isValid()) {
  ...
} else {
  print("Ein Fehler ist aufgetreten: ${merged.errorMessage}");
}
```
## Beispiel: Stundenplan mit Phasierung ausgeben

```dart
import 'api/usersession.dart';
import 'api/timetable.dart';
import 'excel/validator.dart';
import 'excel/models/mergedtimetable.dart';
import 'api/models/timetable.day.dart';
import 'api/models/timetable.hour.dart';
import 'excel/models/phaseelement.dart';

void main() {

  UserSession gw = new UserSession(school: "bbs1-mainz", appID: "testAPP");
  gw.createSession(username: "username", password: "password").then((e) async {
    
    TimeTableRange timetable = await gw.getRelativeTimeTableWeek(-1); 
    
    ExcelValidator validator = ExcelValidator("localhost", "C:/excel/model1.xlsx");
    MergedTimeTable merged = await validator.mergeExcelWithTimetable(timetable);
    
    if(merged.verified()) {
      
      for(TimeTableDay day in timetable.getDays()) {
        for(TimeTableHour hour in day.getHours()) {

          MappedPhase phase = merged.getPhaseForHour(hour);

          print(hour.getSubject().name);
          print(phase.getFirstHalf().name + " " + phase.getFirstHalf().color.toString());
          print(phase.getSecondHalf().name + " " + phase.getFirstHalf().color.toString());

        }
      }

    } else {
      print(merged.errorMessage);
    } 

    await gw.logout();
  });
}
```

## Excel Server ausführen:

Ausführbare Programme finden sich unter:
> /ExcelServer/binaries/

Dieses Programm lässt sich generell mit 2 Argumenten konfigurieren:
- Maximale Anzahl an Clients, die gleichzeitig verbunden sein dürfen.
- Maximale Zeit, die ein Client mit dem Server verbunden sein darf (Angegeben in Millisekunden!)

Beide Dateien benötigen eine Java installation
- Min JRE Version: 1.8
- Max JRE Version: 1.11

### EXE Datei ausführen

Die Exe Datei besitzt beide Argumente vordefiniert: **10 Clients und Maximal 10 Sekunden timeout.**<br>
Diese lässt sich auf Windows Systemen mit einem einfache Doppelklick öffnen.<br>
Um Aktionen zu überwachen öffnen sich ein Konsolenfenster in dem alles geloggt wird.

### JAR Datei ausführen

Diese Datei lässt sich nur anständig in einem Terminal ausführen.
Man kann aber beide Argumente selbst bestimmen.

- Zum Pfad welchseln in der die jar gespeichert ist.
- Folgenden Befehl ausführen:
```java -Xmx1G -jar excelServer.jar 10 10000```

## Server Funktionen

Grundlegend ist es möglich Befehle an den Server mittels eines einfachen Strings über ein TCP Socket zu senden.
Pro Verbindungsaufbau ist die Befehlszahl auf 1 begrenzt. Bevor die Verbindung vom Server getrennt wird.<br>
Man kann jedoch mehrere Befehle mit einem ";" getrennt senden, die dann gleichzeitig ausgeführt werden.

Wenn Daten vom Server generiert werden, werden sie im JSON Format zurückgegeben.
Es folgt eine kleine Liste möglicher Befehle.

#### convertxssf

## Patchnotes

### 1.0.1
- Behebung einer Schwachstelle.
- Detaillierteres Logging für besseres Monitoring
- Es werden nurnoch Errors geloggt
- Maximale gleichzeitige Client Verbindungen und timeout können unbegrenzt gesetzt werden wenn diese Werte kleiner als 0 sind

### Zukunft
- Excel Verifizierung komplett auf den Server auslagern
- Server commands für bessere Administration
- Log Datei für alles erstellen für besseres Monitoring

# Excel Server dependencies:

- <a>https://github.com/DevKevYT/devscript</a> version: '1.9.1'<br>
- <a>https://mvnrepository.com/artifact/org.apache.poi/poi</a> version: '5.1.0'<br>
- <a>https://mvnrepository.com/artifact/org.apache.poi/poi-ooxml</a> version: '5.1.0'<br>
- <a>https://mvnrepository.com/artifact/org.apache.xmlbeans/xmlbeans</a> version: '2.3.0'<br>
- <a>https://mvnrepository.com/artifact/dom4j/dom4j</a> version: '1.6.1'<br>
- <a>https://mvnrepository.com/artifact/org.apache.commons/commons-collections4</a> version: '4.3'<br>
- <a>https://mvnrepository.com/artifact/org.apache.commons/commons-compress</a> version: '1.18'<br>
- <a>https://mvnrepository.com/artifact/org.apache.poi/ooxml-schemas</a> version: '4.1'
