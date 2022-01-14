/*Author Philipp Gersch */

import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import '../api/timetable.dart';
import '../api/models/timetable.hour.dart';
import '../exceptions.dart';
import 'models/cellcolors.dart';
import 'models/phaseelement.dart';
import 'models/mergedtimetable.dart';
import 'models/mappedsheet.dart';

///Mappt Koordinaten der Excel auf den Stundenplan
class MappedPhase {
  PhaseCodes _secondHalf = PhaseCodes.unknown;
  PhaseCodes _firstHalf = PhaseCodes.unknown;

  //x / y Index in der Excel
  int _excelXIndex = 0;
  int _excelYIndex = 0;

  //x / y index auf dem Stundenplan
  int _timetableXIndex = 0;
  int _timetableYIndex = 0;

  ///Die Phasierung der ersten Hälfte dieser Stunde
  PhaseCodes getFirstHalf() {
    return _firstHalf;
  }

  ///Die Phasierung der zweiten Hälfte dieser Stunde
  PhaseCodes getSecondHalf() {
    return _secondHalf;
  }

  ///Der Stundenindex auf der x ebene (Tage)
  ///
  ///Kann auch direkt in `TimeTableRange.getHourByIndex(xIndex, yIndex)` benutzt werden
  int getHourXIndex() {
    return _timetableXIndex;
  }

  ///Der Stundenindex auf der y ebene (Stunden)
  ///
  ///Kann auch direkt in `TimeTableRange.getHourByIndex(xIndex, yIndex)` benutzt werden
  int getHourYIndex() {
    return _timetableYIndex;
  }
}

///Der "Excel Validator" dient dazu, eine Excel Datei zu überprüfen und wenn diese richtig ist, dem Stundenplan die Phasierung zuzuweisen.
///
///Das ist eine Beta Version. In dieser darf nur die Excel für eine Woche enthalten sein. In kommenden Versionen wird
///auch der komplett enthaltene Block verarbeitet werden können.
class ExcelValidator {
  final String _path;
  Excel? _excel;

  bool _queryActive = false;

  final String excelServerAddr;
  final int excelServerPort = 6969;

  //Speichere die Farben um beim mehrfachen aufrufen der mergeExcelWithTimetable() Funktion keinen unnötigen traffic zu erzeugen.
  CellColors _colorData = CellColors();
  var _mapped = <MappedSheet>[];

  ///Startdatum des Blocks
  ///Das gemappte Sheet ist automatisch nicht mehr gültig wenn:
  ///* Das Datum größer als das Startdatum des Blocks ist und die Woche keine Schulwoche ist
  static DateTime? _validDateStart;
  static DateTime?
      _validDateEnd; //TODO static wegmachen wenn nicht bei jedem Stundenplanladen eine neue ExcelValidator instanz erstellt wird ...

  ///Der Excel Validator dient dazu den Stundenplan mit der angegebenen Phasierung zu verbinden.
  ///Dieser ist komplett unabhängig zum Stundenplanobjekt.
  ///
  ///[_path] Der lokale Pfad zur Excel Datei
  ///[EXCEL_SERVER_ADDR] Die Serveradresse eines excel Servers ohne Portangabe
  ExcelValidator(this.excelServerAddr, this._path) {
    if (_path.isEmpty) throw Exception("Der Pfad existiert nicht");

    var bytes = File(_path).readAsBytesSync();
    _excel = Excel.decodeBytes(bytes);
    print("Creating new validator instance ...");
  }

  ///Mit dieser Funktion kann ein geladener Phasierungsplan auf einen Schulblock beschränkt werden.
  ///
  ///Das Datum ist das Datum des aktuellen Block Startes (Montag).
  ///Funktion kann benutzt werden um das Datum manuell aus dem Speicher zu setzten bis der user z.B. eine neue
  ///Excel lädt und damit ein neues Objekt erzeugt.
  ///
  ///Eine Phasierung wird als ungültig betrachtet wenn ein verglichenes Datum:
  ///* Kleiner als [datetime] ist
  ///* Größer als [datetime] ist und die aktuelle Woche keine Schulwoche ist
  void limitPhasePlanToCurrentBlock(DateTime startDate, DateTime endDate) {
    _validDateStart = startDate;
    _validDateEnd = endDate;
  }

  DateTime? getBlockStart() {
    return _validDateStart;
  }

  DateTime? getBlockEnd() {
    return _validDateEnd;
  }

  ///Verifiziert die im Konstruktor angegebene Excel Datei und überprüft, ob der Stundenplan enthalten ist.
  ///Diese funktion kann mehrmals mit verschiedenen Stundenplänen aufgerufen werden.
  ///
  ///Funktioniert aktuell nur mit der aktuellen Woche oder wenn [timetable] durch `UserSession.getRelativeTimeTableForWeek()` erzeugt wurde.
  ///
  ///Der optionale Parameter [refresh] gibt an, ob gecachte excel sheets neu verifiziert werden sollen.
  ///
  ///Folgende Errors kann diese Funktion werfen (Alle zu finden in '/exceptions.dart')
  ///* `ExcelMergeNonSchoolBlockException`: Wenn die Woche keine Schulblockwoche ist
  ///* `ExcelMergeTimetableNotMatchException`: Wenn die angegebene Woche in der Excel nicht dem angegebenen Stundenplan entspricht
  ///* `ExcelMergeTimetableNotFound`: Wenn die angegebene Woche nicht in der Excel gefunden werden konnte
  ///* `ExcelMergeFileNotVerified`: Wenn kein Stundenplan in der Excel gefunden werden konnte
  ///* `ExcelConversionAlreadyActive`: Wenn diese Funktion bereits aufgerufen wurde und noch nicht fertig ist
  ///* `ExcelConversionServerError`: Wenn ein Fehler Serverseitig aufgetreten ist
  ///* `FailedToEstablishExcelServerConnection`: Wenn keine Verbindung zum Excel Server hergestellt werden konnte
  ///* `CurrentPhaseplanOutOfRange`: Wenn die timetable Stunden hat die aber außerhalb des aktuellen Blockes sind.
  Future<MergedTimeTable> mergeExcelWithTimetable(TimeTableRange timetable, {bool refresh = false}) async {
    //TODO Noch nicht voll debuggt. Bitte überwachen. Das Datum soll den ersten und letzten Tag des nächsten oder aktuellen Blocks sein
    _validDateStart ??= await timetable.getNextBlockStartDate(0);
    _validDateEnd ??= await timetable.getNextBlockEndDate(0);

    print(_validDateStart);
    print(_validDateEnd);
    if (timetable.isNonSchoolblockWeek()) {
      throw ExcelMergeNonSchoolBlockException("Diese Woche enthält keine Schulstunden");
    } else {
      if (_validDateStart != null) {
        if (timetable.getDays()[0].getDate().millisecondsSinceEpoch < _validDateStart!.millisecondsSinceEpoch) {
          throw CurrentPhaseplanOutOfRange("Dieser Schulblock gehört nicht mehr zur Phasierung!");
        }
      }

      if (_validDateEnd != null) {
        if (timetable.getDays()[0].getDate().millisecondsSinceEpoch >= _validDateEnd!.millisecondsSinceEpoch) {
          throw CurrentPhaseplanOutOfRange("Dieser Schulblock gehört nicht mehr zur Phasierung!");
        }
      }
    }

    if (_mapped.isEmpty || refresh) {
      _mapped = await _verifySheet(timetable);
    }

    if (_mapped.isNotEmpty) {
      int currentWeek = await timetable.getCurrentBlockWeek(timetable.relativeToCurrent);

      for (MappedSheet mapped in _mapped) {
        mapped.estimateWeek();

        if (currentWeek + 1 == mapped.blockWeek) {
          //+1 weil currentWeek nur der Index ist der bei 0 anfängt

          //Schließlich vergleiche und verifiziere diesen stundenplan mit dem gemappten Index
          MappedSheet verified =
              _searchRange(_mapped[currentWeek].sheet, timetable, startX: mapped.rawX, startY: mapped.rawY);

          if (verified.startX == mapped.startX &&
              verified.startY == mapped.startY &&
              verified.width == mapped.width &&
              verified.height == mapped.height) {
            //Nicht super schön, aber fürs erste ok
            while (_colorData.isEmpty() || _colorData.failed) {
              await _loadColorData(forceReload: false);
            }

            for (MappedPhase hour in mapped.getHours()) {
              //die x und y sind IMMER die ersten hälften der stunde. Also y+1 ist die 2. hälfte
              hour._firstHalf = PhaseColor.estimatePhaseFromColor(
                  _colorData.getColorForCell(xIndex: hour._excelXIndex, yIndex: hour._excelYIndex));
              hour._secondHalf = PhaseColor.estimatePhaseFromColor(
                  _colorData.getColorForCell(xIndex: hour._excelXIndex, yIndex: hour._excelYIndex + 1));
            }

            //##############################
            //          Fertig :)
            //##############################

            return MergedTimeTable(timetable, mapped);
          } else {
            throw ExcelMergeTimetableNotMatchException(
                "Der Excel Stundenplan für Woche ${currentWeek + 1} passt nicht zum angegebenen Stundenplan.");
          }
        }
      }
      throw ExcelMergeTimetableNotFound(
          "Stelle sicher, dass in der Excel ein Stundenplan mit der überschrift 'Woche ${currentWeek + 1}' existiert und dieser auch in die angegebene Woche passt.");
    }

    throw ExcelMergeFileNotVerified("Es konnte kein Stundenplan auf der Excel Datei gefunden werden.");
  }

  ///Sendet eine Anfrage an den Server in 4 Schritten:
  ///* Den befehl: In diesem Fall "convertxssf". Dieser signalisiert dem Server, dass gleich eine Excel Datei kommt, die er bitte umwandeln soll (Zellenfarben)
  ///* Warten auf die Bestätigung: Wenn der Server berit ist die Excel zu empfangen, sendet er ein "ready" zurück.
  ///* Excel als Stream an den Server senden
  ///* Daten in ein "CellColors" Objekt umwandeln und zurückgeben
  ///
  ///Wenn ein Error auftritt wird er geworfen.
  ///Diese Funktion kann nicht aufgerufen werden bis eine gestellte Abfrage abgearbeitet wurde.
  Future<CellColors> _loadColorData({bool forceReload = false}) async {
    if (!_colorData.isEmpty() && !forceReload) return _colorData;

    _colorData = CellColors();

    if (_queryActive) {
      throw ExcelConversionAlreadyActive("Zellenfarben werden bereits beschafft");
    }

    try {
      _queryActive = true;
      final socket = await Socket.connect(excelServerAddr, excelServerPort);

      //Sende den Befehl
      socket.writeln("convertxssf");
      await socket.flush();

      var subscription = socket.listen((event) async {
        // String message = String.fromCharCodes(event);
        // print(String.fromCharCodes(event));
        dynamic decodedMessage = "";
        try {
          decodedMessage = jsonDecode(String.fromCharCodes(event));
        } on FormatException {
          _colorData = CellColors(data: null, failed: true);
          socket.close();
          return;
        }

        if (decodedMessage['error'] != null) {
          throw ExcelConversionServerError(
              "Ein Fehler ist bei der Beschaffung der Zellenfarben aufgetreten: " + decodedMessage['error']);
        }

        if (decodedMessage['message'] != null) {
          if (decodedMessage['message'] == "ready-for-file") {
            await socket.addStream(File(_path).openRead());
          } else {
            _colorData = CellColors(data: decodedMessage['data']);
          }
        }
      }, onError: (error) {
        _queryActive = false;
        throw ExcelConversionServerError("Ein Fehler ist bei der Beschaffung der Zellenfarben aufgetreten: " + error);
      }, onDone: () {
        //Alles OK!
        _queryActive = false;
      });

      await subscription.asFuture<void>();
      await socket.close();
      _queryActive = false;
      return _colorData;
    } on Exception {
      _queryActive = false;
      throw FailedToEstablishExcelServerConnection(
          "Konnte keine Verbindung zum Konvertierungsserver " + excelServerAddr + " herstellen.");
    }
  }

  ///Das sheet konnte nicht verifiziert werden, wenn das gemappte sheet leer ist
  Future<List<MappedSheet>> _verifySheet(TimeTableRange range) async {
    //Alle Stundenpläne die in der Excel enthalten sind
    var mappedSheets = <MappedSheet>[];

    for (var table in _excel!.sheets.keys) {
      for (int i = 0; i < _excel!.tables[table]!.maxCols; i++) {
        for (int j = 0; j < _excel!.tables[table]!.maxRows; j++) {
          if (_worthSearching(mappedSheets,
              xIndex: i,
              yIndex: j,
              excelWidth: _excel!.tables[table]!.maxCols,
              excelHeight: _excel!.tables[table]!.maxRows)) {
            MappedSheet mappedTimetable = _searchRange(_excel!.tables[table]!, range, startX: i, startY: j);

            if (mappedTimetable.isValid()) {
              mappedSheets.add(mappedTimetable);
            }
          }
        }
      }
    }
    return mappedSheets;
  }

  //Errechnet mit den Excel boundaries und bestehenden Stundenplänen ob es sich lohnt den aktuellen index nach einem Stundenplan abzusuchen.
  //Einfach nur um den Code etwas schneller zu machen
  bool _worthSearching(List<MappedSheet> mappedSheets,
      {int xIndex = 0, int yIndex = 0, int excelWidth = 0, int excelHeight = 0}) {
    bool worth = true;

    for (MappedSheet existing in mappedSheets) {
      if (xIndex >= existing.startX &&
          xIndex < existing.width &&
          yIndex >= existing.startY &&
          yIndex < existing.height) {
        return false;
      }
      //if(xIndex + 5 > existing.startX && xIndex + 5 < existing.startX + existing.width
      //  || yIndex + 8 > existing.startY && yIndex +5 < existing.startY + existing.height) {
      //  return false;
      //}
    }

    return worth;
  }

  MappedSheet _searchRange(Sheet sheet, TimeTableRange range, {int startX = 0, int startY = 0}) {
    MappedSheet mapped = MappedSheet(sheet);
    if (sheet.cell(CellIndex.indexByColumnRow(columnIndex: startX, rowIndex: startY)).value == null) {
      return mapped;
    }

    int excelX = startX;
    int excelY = startY;

    for (int tx = 0; tx < range.getDays().length - 2; tx++, excelX++) {
      excelY = startY;
      for (int ty = 0; ty < 8; ty++, excelY++) {
        TimeTableHour hour = range.getHourByIndex(xIndex: tx, yIndex: ty);
        Data cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: excelX, rowIndex: excelY));

        if (hour.getLessonCode() == Codes.irregular) {
          hour = hour.getReplacement();
        }

        String cellValueString = cell.value == null ? "null" : cell.value.toString();

        if (cellValueString.toLowerCase().contains(hour.getTeacher().name.toString().toLowerCase()) ||
            hour.getTeacher().name == "---" ||
            cellValueString == "null" ||
            hour.getLessonCode() == Codes.empty) {
          MappedPhase phase = MappedPhase();

          phase._excelXIndex = excelX;
          phase._excelYIndex = excelY;
          phase._timetableXIndex = hour.xIndex;
          phase._timetableYIndex = hour.yIndex;

          mapped.addHour(phase);

          excelY++;
        } else {
          return mapped;
        }
      }
    }

    mapped.rawX = startX;
    mapped.rawY = startY;
    //-1: Erst mal davon ausgehen, dass über den Stunden der Tag angegeben ist (Und darüber die Woche vom Block) und links die Stundennummern
    mapped.startX = startX - 1;
    mapped.startY = startY - 2 < 0 ? (startY - 1 < 0 ? startY : startY - 1) : startY - 2;
    //Etwas irreführend. excelX und y werden durch den loop erhöht. Dadurch ergibt sich am ende automatisch die höhe und Breite
    mapped.width = excelX - 1;
    mapped.height = excelY - 1;

    mapped.setValid();
    return mapped;
  }
}
