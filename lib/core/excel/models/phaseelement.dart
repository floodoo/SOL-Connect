enum PhaseCodes {
  orienting,
  reflection,
  structured,
  free,
  feedback,
  unknown //<- Wenn der Lehrer nix eingetragen hat *hust* DEC *hust*    oder Ferien sind oder so ...
}

class Phase {
  PhaseCodes identifier = PhaseCodes.unknown;
  int xIndex = 0;
  int yIndex = 0;
}
