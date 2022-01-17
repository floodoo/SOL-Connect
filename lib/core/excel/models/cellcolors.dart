/*Author Philipp Gersch */

import 'phaseelement.dart';

class _ColorEntry {
  int _xIndex = 0;
  int _yIndex = 0;
  PhaseColor _color = PhaseColor(0, 0, 0);
}

class CellColors {
  final _colorEntries = <_ColorEntry>[];
  bool failed = false;

  ///Erwartet eine Liste von Zellen
  CellColors({dynamic data, this.failed = false}) {
    if (data == null) return;

    for (dynamic cell in data) {
      _ColorEntry entry = _ColorEntry();
      entry._xIndex = cell['x'];
      entry._yIndex = cell['y'];
      entry._color = PhaseColor(cell['c']['r'], cell['c']['g'], cell['c']['b']);
      _colorEntries.add(entry);
    }
  }

  bool isEmpty() {
    return _colorEntries.isEmpty;
  }

  PhaseColor getColorForCell({int xIndex = 0, int yIndex = 0}) {
    for (_ColorEntry entry in _colorEntries) {
      if (entry._xIndex == xIndex && entry._yIndex == yIndex) {
        return entry._color;
      }
    }
    return PhaseColor(0, 0, 0);
  }
}
