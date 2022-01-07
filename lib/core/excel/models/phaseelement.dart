/*Author Philipp Gersch */

enum PhaseCodes {
  orienting,
  reflection,
  structured,
  free,
  feedback,
  unknown //<- Wenn der Lehrer nix eingetragen hat *hust* DEC *hust*    oder Ferien sind oder so ...
}

extension Phase on PhaseCodes {
  Color get color {
    switch (this) {
      case PhaseCodes.orienting:
        return Color.PHASE_ORIENTING;
      case PhaseCodes.reflection:
        return Color.PHASE_REFLECTION;
      case PhaseCodes.structured:
        return Color.PHASE_STRUCTURED;
      case PhaseCodes.free:
        return Color.PHASE_FREE;
      case PhaseCodes.feedback:
        return Color.PHASE_FEEDBACK;
      default:
        return Color(0, 0, 0);
    }
  }
}

class Color {
  ///Maximale Abweichung der angegebenen Farbe
  static const int maxRGBDeviation = 5;

  static final Color PHASE_ORIENTING = Color(255, 192, 0);
  static final Color PHASE_REFLECTION = Color(255, 255, 0);
  static final Color PHASE_STRUCTURED = Color(0, 176, 240);
  static final Color PHASE_FREE = Color(146, 208, 80);
  static final Color PHASE_FEEDBACK = Color(255, 0, 0);

  final int r, g, b;

  Color(this.r, this.g, this.b);

  static PhaseCodes estimatePhaseFromColor(Color color) {
    for (PhaseCodes code in PhaseCodes.values) {
      if (_inRange(need: code.color.r, isvalue: color.r) &&
          _inRange(need: code.color.g, isvalue: color.g) &&
          _inRange(need: code.color.b, isvalue: color.b)) {
        return code;
      }
    }
    return PhaseCodes.unknown;
  }

  static bool _inRange({int isvalue = 0, int need = 0}) {
    return isvalue >= need - maxRGBDeviation && isvalue <= need + maxRGBDeviation;
  }

  String toString() {
    return r.toString() + ", " + g.toString() + ", " + b.toString();
  }
}
