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
  PhaseColor get color {
    switch (this) {
      case PhaseCodes.orienting:
        return PhaseColor.phaseOrienting;
      case PhaseCodes.reflection:
        return PhaseColor.phaseReflection;
      case PhaseCodes.structured:
        return PhaseColor.phaseStructured;
      case PhaseCodes.free:
        return PhaseColor.phaseFree;
      case PhaseCodes.feedback:
        return PhaseColor.phaseFeedback;
      default:
        return PhaseColor(0, 221, 0);
    }
  }
}

class PhaseColor {
  ///Maximale Abweichung der angegebenen Farbe
  static const int maxRGBDeviation = 5;

  static final PhaseColor phaseOrienting = PhaseColor(255, 192, 0);
  static final PhaseColor phaseReflection = PhaseColor(255, 255, 0);
  static final PhaseColor phaseStructured = PhaseColor(0, 176, 240);
  static final PhaseColor phaseFree = PhaseColor(146, 208, 80);
  static final PhaseColor phaseFeedback = PhaseColor(255, 0, 0);

  final int r, g, b;

  PhaseColor(this.r, this.g, this.b);

  static PhaseCodes estimatePhaseFromColor(PhaseColor color) {
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

  @override
  String toString() {
    return r.toString() + ", " + g.toString() + ", " + b.toString();
  }
}
