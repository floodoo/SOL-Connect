import 'dart:convert';
import 'phaseelement.dart';
import '../../exceptions.dart';

class ColorEntry {
  int _xIndex = 0;
  int _yIndex = 0;
  Color _color = Color(0, 0, 0);
}

class CellColors {

  final _colorEntries = <ColorEntry>[];

  CellColors({String jsonData = ""}) {
    
    if(jsonData.isEmpty) return;

    dynamic json = jsonDecode(jsonData);

    if(json['message'] != "ok") {
      throw Exception("The conversion Server emitted an Error: " + json['message']);
    }

    for(dynamic cell in json['cells']) {
      ColorEntry entry = ColorEntry();
      entry._xIndex = cell['x'];
      entry._yIndex = cell['y'];
      entry._color = Color(cell['c']['r'], cell['c']['g'], cell['c']['b']);
      _colorEntries.add(entry);
    }
  }

  bool isEmpty() {
    return _colorEntries.isEmpty;
  }

  Color getColorForCell({int xIndex: 0, int yIndex: 0}) {
    for(ColorEntry entry in _colorEntries) {
      if(entry._xIndex == xIndex && entry._yIndex == yIndex) {
        return entry._color;
      }
    }
    return new Color(0, 0, 0);
  }
}