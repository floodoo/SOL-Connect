Beispiel für eine Wochenabfrage:
```dart

void main() {

  UserSession gw = new UserSession(school: "bbs1-mainz", appID: "testAPP");

  gw.createSession(username: "USERNAME", password: "PASSWORD").then((e) async {

    TimeTableRange week = await gw.getTimeTableForThisWeek();

    for (TimeTableDay day in week.getDays()) {

      if (day.isHolidayOrWeekend()) print("\t[FERIEN/WOCHENENDE]");

      for (TimeTableHour hour in day.getHours()) {
        print("\t" +
            hour.getTitle() +
            " " +
            hour.getSubject().name +
            " " +
            (hour.code != "regular" ? "[" + hour.code + "]" : ""));*/
      }
    }
  });
}
```
