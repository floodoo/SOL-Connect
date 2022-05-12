/*Author Philipp Gersch */

/// Wandelt ein DateTime objekt in ein Webuntis Date objekt um.
/// Dieses Datenformat setzt sich folgendermaßen zusammen:
/// YYYYMMDD

class Utils {
  ///Gibt einen String im Format YYYYMMDD zurück
  static String convertToUntisDate(DateTime date) {
    return ((date.year >= 1000 ? date.year.toString() : "1970") +
        (date.month < 10 ? '0${date.month}' : date.month.toString()) +
        (date.day < 10 ? '0${date.day}' : date.day.toString()).toString());
  }

  ///Wandelt einen String im Format YYYYMMDD in ein DateTime Objekt um
  static DateTime convertToDateTime(String untisDate) {
    return DateTime.parse(untisDate);
  }

  ///Tage seit 01.01.1970
  static int daysSinceEpoch(int timestamp) {
    return (timestamp / (1000 * 60 * 60 * 24)).floor();
  }

  static bool dateInbetweenDays({required DateTime from, required DateTime to, DateTime? current}) {
    int fromd = Utils.daysSinceEpoch(from.millisecondsSinceEpoch);
    int tod = Utils.daysSinceEpoch(to.millisecondsSinceEpoch);
    int currentd =
        Utils.daysSinceEpoch(current == null ? DateTime.now().millisecondsSinceEpoch : current.millisecondsSinceEpoch);

    return currentd >= fromd && currentd <= tod;
  }

  ///Gibt true zurück, wenn nur Tag, Monat und Jahr gleich sind. ZEiten können verschieden sein
  static bool dayMatch(DateTime d1, DateTime d2) {
    return d1.day == d2.day && d1.month == d2.month && d1.year == d2.year;
  }

  ///Gibt true zurück, wenn d1 mehr oder genauso viele Tage wie d2 seit 1970 hat
  static bool dayGreaterOrEqual(DateTime d1, DateTime d2) {
    return daysSinceEpoch(d1.millisecondsSinceEpoch) >= daysSinceEpoch(d2.millisecondsSinceEpoch);
  }

  //Schneidet einfach die Zeit weg, sodass nurnoch jahre, monate und Tage im Datum enthalten sind (Alles andere wird 0)
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String convertToDDMMYY(DateTime? date) {
    if (date == null) {
      return "?";
    }

    String d = convertToUntisDate(date);
    return "${d.substring(6)}.${d.substring(4, 6)}.${d.substring(2, 4)}";
  }

  ///Gibt true zurück, wenn das Da
  bool dateInRange({required DateTime start, required DateTime end, required DateTime current}) {
    return current.millisecondsSinceEpoch > start.millisecondsSinceEpoch &&
        current.millisecondsSinceEpoch < end.millisecondsSinceEpoch;
  }

  ///Wandelt ein DateTime objekt in das Format DDMM um
  static String convertToDDMM(DateTime? date) {
    if (date == null) {
      return "?";
    }

    String d = convertToUntisDate(date);
    return "${d.substring(6)}.${d.substring(4, 6)}";
  }
}
