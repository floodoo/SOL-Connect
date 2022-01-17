/*Author Philipp Gersch */

/// Wandelt ein DateTime objekt in ein Webuntis Date objekt um.
/// Dieses Datenformat setzt sich folgendermaßen zusammen:
/// YYYYMMDD
String convertToUntisDate(DateTime date) {
  return (date.year.toString() +
      (date.month < 10 ? '0' + date.month.toString() : date.month.toString()) +
      (date.day < 10 ? '0' + date.day.toString() : date.day.toString()).toString());
}

DateTime convertToDateTime(String untisDate) {
  return DateTime.parse(untisDate);
}

int daysSinceEpoch(int timestamp) {
  return (timestamp / (1000 * 60 * 60 * 24)).floor();
}

///Gibt true zurück, wenn nur Tag, Monat und Jahr gleich sind. ZEiten können verschieden sein
bool dateMatch(DateTime d1, DateTime d2) {
  return d1.day == d2.day && d1.month == d2.month && d1.year == d2.year;
}

String convertToDDMM(DateTime? date) {
  if (date == null) {
    return "?";
  }

  String d = convertToUntisDate(date);
  return d.substring(6) + "." + d.substring(4, 6);
}
