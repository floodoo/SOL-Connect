import 'dart:io';
import 'package:excel/excel.dart';

class ExcelValidator {
  String _path = "";
  Excel? excel;

  ExcelValidator(this._path) {
    excel = ExcelValidator.readExcelFile(path: this._path);

    for (var table in excel!.sheets.keys) {
      print(excel!.tables[table]!.maxCols);
    }
  }

  static Excel readExcelFile({String path = ""}) {
    if (path.isEmpty) throw Exception("Der Pfad existiert nicht");

    var bytes = File(path).readAsBytesSync();
    return Excel.decodeBytes(bytes);
  }
}
