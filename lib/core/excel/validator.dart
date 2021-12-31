import 'dart:io';
import 'package:excel/excel.dart';
import '../api/timetable.dart';
import '../api/models/timetable.hour.dart';
import '../exceptions.dart';
import 'models/cellcolors.dart';

///Der "Excel Validator" dient dazu, eine Excel Datei zu überprüfen und wenn diese richtig ist, dem Stundenplan die Phasierung zuzuweisen.
///
///Das ist eine Beta Version. In dieser darf nur die Excel für eine Woche enthalten sein. In kommenden Versionen wird
///auch der komplett enthaltene Block verarbeitet werden können.
class ExcelValidator {
  
  String _path = "";
  Excel? excel;
  bool _valid = false;
  TimeTableRange _timetable;

  final bool debug = false;
  bool _queryActive = false;

  ///[_path] Der lokale Pfad zur Excel Datei
  ///
  ///[_timetable] Der bereits geladene Stundenplan
  ExcelValidator(this._path, this._timetable) {

    if (_path.isEmpty) throw Exception("Der Pfad existiert nicht");

    var bytes = File(_path).readAsBytesSync();
    excel = Excel.decodeBytes(bytes);
    _valid = _verifySheet(_timetable);
  }

  bool isValid() {
    return _valid;
  }

  ///Sendet eine Anfrage an den Server in 4 Schritten:
  ///* Den befehl: In diesem Fall "convertxssf". Dieser signalisiert dem Server, dass gleich eine Excel Datei kommt, die er bitte umwandeln soll (Zellenfarben)
  ///* Warten auf die Bestätigung: Wenn der Server berit ist die Excel zu empfangen, sendet er ein "ready" zurück.
  ///* Excel als Stream an den Server senden
  ///* Daten in ein "CellColors" Objekt umwandeln und zurückgeben
  ///
  ///Wenn ein Error auftritt wird er geworfen.
  ///Diese Funktion kann nicht aufgerufen werden bis eine gestellte Abfrage abgearbeitet wurde.
  Future<CellColors> getColorData() async {
    CellColors colors = new CellColors();
    
    if(_queryActive) {
      throw ExcelConversionAlreadyActive(cause: "Zellenfarben werden bereits beschafft");
    }

    try {
      
      _queryActive = true;

      final socket = await Socket.connect('localhost', 6969);    

      //Sende den Befehl
      socket.write("convertxssf\r\n");
      await socket.flush();

      var subscription = socket.listen( 
        
        (event) async {
          String message = new String.fromCharCodes(event);

          if(message.trim() == "ready") {
            await socket.addStream(File(_path).openRead());
          } else {
            colors = CellColors(jsonData: message.trim());
          }
        },

        onError: (error) {
          _queryActive = false;
          throw Exception("Ein Fehler ist bei der Beschaffung der Zellenfarben aufgetreten: " + error);
        },

        onDone: () {
          //Alles OK!
          _queryActive = false;
        }
      );

      await subscription.asFuture<void>();
      return colors;

    } catch(e) {
      _queryActive = false;
      throw Exception("Konnte keine Verbindung zum Konvertierungsserver {addr} herstellen.");
    }
  }

  bool _verifySheet(TimeTableRange range) {

    for(var table in excel!.sheets.keys) {   
      for(int i = 0; i < excel!.tables[table]!.maxCols; i++) {
        for(int j = 0; j < excel!.tables[table]!.maxRows; j++) {

          if(debug) print("--> Searching in " + i.toString() + " " + j.toString());
          if(i == 1 && j == 2) {
            print("");
          }
         
          if(_searchRange(excel!.tables[table]!, range, startX: i, startY: j)) {
            
            //Hole Zellenfarben erst wenn die Datei erfolgreich verifiziert wurde.
            
            return true;
          }

        }
      }
    }
    return false;
  }

  //Das ist ultra abgefuckt ...
  //Der Cellname ist wie in Excel. Z.B. A0 oder C3
  //String getCellColor(Sheet sheet, String cellName) {
   // 
  //}

  bool _searchRange(Sheet sheet, TimeTableRange range, {int startX = 0, int startY = 0}) {
    
    if(sheet.cell(CellIndex.indexByColumnRow(columnIndex: startX, rowIndex: startY)).value == null) {
      return false;
    }

    for(int tx = 0, excelX = startX; tx < range.getDays().length; tx++, excelX++) {
      for(int ty = 0, excelY = startY; ty < 8; ty++, excelY++) {

        TimeTableHour hour = range.getHourByIndex(xIndex: tx, yIndex: ty);
        Data cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: excelX, rowIndex: excelY));
        
        if(hour.getLessonCode() == Codes.irregular) {
          hour = hour.getReplacement();
        }
        
        if(debug) print("Excel: (" + excelX.toString() + "|" + excelY.toString()  + "): '" 
          + cell.value.toString() +  "' TT: (" + tx.toString() + "|" + ty.toString() + "): '" + hour.toString() + "'");

        String cellValueString = cell.value == null ? "null" : cell.value.toString();
        
        if(cell.cellStyle != null) print(cell.cellStyle!.backgroundColor);

        if(cellValueString.toLowerCase().contains(hour.getTeacher().name.toString().toLowerCase()) || hour.getTeacher().name == "---" || 
          cellValueString == "null" || hour.getLessonCode() == Codes.empty) {
          
          if(debug) print(cellValueString + " matches hour " + hour.toString()); 
          excelY++;

        } else return false;
      }
    }
      
    return true;
  }
}
