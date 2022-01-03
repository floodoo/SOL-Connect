/*Author Philipp Gersch*/

import 'dart:convert';
import 'phaseelement.dart';

class _ColorEntry {
  int _xIndex = 0;
  int _yIndex = 0;
  Color _color = Color(0, 0, 0);
}

class CellColors {

  final _colorEntries = <_ColorEntry>[];

  CellColors({String jsonData = ""}) {
    
    if(jsonData.isEmpty) return;

    dynamic json = jsonDecode(jsonData);

    if(json['message'] != "ok") {
      throw Exception("The conversion Server emitted an Error: " + json['message']);
    }

    for(dynamic cell in json['cells']) {
      _ColorEntry entry = _ColorEntry();
      entry._xIndex = cell['x'];
      entry._yIndex = cell['y'];
      entry._color = Color(cell['c']['r'], cell['c']['g'], cell['c']['b']);
      _colorEntries.add(entry);
    }
  }

  bool isEmpty() {
    return _colorEntries.isEmpty;
  }

  Color getColorForCell({int xIndex = 0, int yIndex = 0}) {
    for(_ColorEntry entry in _colorEntries) {
      if(entry._xIndex == xIndex && entry._yIndex == yIndex) {
        return entry._color;
      }
    }
    return Color(0, 0, 0);
  }
}