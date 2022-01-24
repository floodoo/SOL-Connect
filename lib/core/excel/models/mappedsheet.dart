/*Author Philipp Gersch */

import 'package:excel/excel.dart';
import 'package:untis_phasierung/core/excel/validator.dart';

///Enthält gemappte Daten von einem Stundenplan in der Excel Datei
class MappedSheet {
  final Sheet sheet;
  //Excel Timetable Boundaries
  int startX = 0, startY = 0;
  int width = 0, height = 0;

  //"Rohe Werte" hier zählt nur die Position der Stundenplan Daten. NIcht aber Zeug darüber oder sonst wo
  int rawX = 0, rawY = 0;

  bool _valid = false;
  final _hours = <MappedPhase>[];
  //Die Block Woche wie sie in der Excel über der Tabelle steht
  int blockWeek = -1;

  MappedSheet(this.sheet);

  List<MappedPhase> getHours() {
    return _hours;
  }

  bool isValid() {
    return _valid;
  }

  void setValid() {
    _valid = true;
  }

  void addHour(MappedPhase phase) {
    _hours.add(phase);
  }

  void estimateWeek() {
    for (int i = 0; i < rawY - startY; i++) {
      for (int i = 0; i < width; i++) {
        var value = sheet.cell(CellIndex.indexByColumnRow(columnIndex: startX + i, rowIndex: startY));
        if (value.value != null) {
          if (value.value.toString().contains(RegExp(r'Woche\s[0-9]', caseSensitive: false))) {
            blockWeek = int.parse(value.value.toString().split(" ")[1]);
            return;
          }
        }
      }
    }
  }
}
