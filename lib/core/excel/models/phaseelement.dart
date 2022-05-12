/*Author Philipp Gersch */

enum PhaseCodes {
  orienting,
  reflection,
  structured,
  free,
  feedback,
  unknown //<- Wenn der Lehrer nix eingetragen hat
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
        return PhaseColor(80, 80, 80);
    }
  }
}

extension PhaseReadables on PhaseCodes {
  String get readableName {
    switch (this) {
      case PhaseCodes.orienting:
        return "Orientierungsphase";
      case PhaseCodes.reflection:
        return "Planungsphase";
      case PhaseCodes.structured:
        return "Strukturierte Phase";
      case PhaseCodes.free:
        return "Freie Phase";
      case PhaseCodes.feedback:
        return "Feedback Phase";
      default:
        return "Keine Info verfügbar";
    }
  }

  String get description {
    switch (this) {
      case PhaseCodes.orienting:
        return "In dieser Phase spricht der Lehrer und gibt Infos für den Block / die nächsten Arbeitsaufträge.\nAußerdem wird organisatorisches erledigt.";
      case PhaseCodes.reflection:
        return "In dieser Phase setzt man seine Ziele und erstellt einen SMART Plan.\nDiese Phase kann auch zur Reflexion von Zielen genutzt werden.";
      case PhaseCodes.structured:
        return "Diese Phase ist durch den Lehrer strukturiert.\nEs gibt feste Materialien / Arbeitsformen für diese Phase.";
      case PhaseCodes.free:
        return "In dieser Phase kann man gemäß der Kann-Listen und SMART-Plänen frei Lernen.";
      case PhaseCodes.feedback:
        return "In dieser Phase gibt man Rückmeldung zum Wochen- oder Blockverlauf.";
      default:
        return "Entweder wurde für dieses Fach keine Phasierung eingetragen, oder diese Phase ist der App unbekannt.";
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
    return "$r, $g, $b";
  }
}
