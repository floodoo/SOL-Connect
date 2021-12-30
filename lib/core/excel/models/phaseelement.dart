enum PhaseCodes {
  orienting,
  reflection,
  structured,
  free,
  feedback,
  unknown //<- Wenn der Lehrer nix eingetragen hat *hust* DEC *hust*    oder Ferien sind oder so ...
}

class Color {
  
  int r = 0, g = 0, b = 0;


}

class Phase {
  //final Map<PhaseCodes, Color> phaseColors = <PhaseCodes, Color>;

  PhaseCodes identifier = PhaseCodes.unknown;
  int xIndex = 0;
  int yIndex = 0;
}
