import 'timetable.hour.dart';

class TimeTableDay {
  DateTime date;
  var hours = <TimeTableHour>[];
  String dayName = "";

  TimeTableDay(this.date) {
    switch (date.weekday) {
      case 1:
        dayName = "Montag";
        break;
      case 2:
        dayName = "Dienstag";
        break;
      case 3:
        dayName = "Mittwoch";
        break;
      case 4:
        dayName = "Donnerstag";
        break;
      case 5:
        dayName = "Freitag";
        break;
      case 6:
        dayName = "Samstag";
        break;
      case 7:
        dayName = "Sonntag";
        break;
      default:
        "";
    }
  }

  void addHour(dynamic data) {
    hours.add(new TimeTableHour(data));

    hours.sort((a, b) => a.end.hour.compareTo(b.end.hour));
  }
}
