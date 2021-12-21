/**Wandelt ein DateTime objekt in ein Webuntis Date objekt um.
 * Dieses Datenformat setzt sich folgendermaßen zusammen:
 * YYYYMMDD
*/
String convertToUntisDate(DateTime date) {
  return (date.year.toString() +
      (date.month < 10
          ? '0' + date.month.toString()
          : date.month.toString() +
              (date.day < 10 ? '0' + date.day.toString() : date.day.toString())
                  .toString()));
}

DateTime convertToDateTime(String untisDate) {
  return DateTime.parse(untisDate);
}
