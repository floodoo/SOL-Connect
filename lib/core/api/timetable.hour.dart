import 'timetable.entity.dart';
import 'utils.dart';

class TimeTableHour {
  TimeTableEntity klasse = TimeTableEntity("", null);
  TimeTableEntity teacher = TimeTableEntity("", null);
  TimeTableEntity subject = TimeTableEntity("", null);
  TimeTableEntity room = TimeTableEntity("", null);

  String activityType = "";
  int id = -1;
  DateTime start = DateTime(0);
  DateTime end = DateTime(0);

  DateTime parseDate(String date, String time) {
    return DateTime.parse(date.substring(0, 4) +
        "-" +
        date.substring(4, 6) +
        "-" +
        date.substring(6, 8) +
        " " +
        (time.length == 3
            ? "0" + time.substring(0, 1) + ":" + time.substring(1) + ":00"
            : time.substring(0, 2) + ":" + time.substring(2) + ":00"));
  }

  TimeTableHour(dynamic data) {
    this.id = data['id'];

    this.start =
        parseDate(data['date'].toString(), data['startTime'].toString());
    this.end = parseDate(data['date'].toString(), data['endTime'].toString());

    this.activityType = data['activityType'];

    this.klasse = new TimeTableEntity("kl", data['kl']);
    this.teacher = new TimeTableEntity("te", data['te']);
    this.subject = new TimeTableEntity("su", data['su']);
    this.room = new TimeTableEntity("ro", data['ro']);
  }

  String getTitle() {
    return (start.hour < 10
            ? "0" + start.hour.toString()
            : start.hour.toString()) +
        ":" +
        (start.minute < 10
            ? "0" + start.minute.toString()
            : start.minute.toString()) +
        " - " +
        (end.hour < 10 ? "0" + end.hour.toString() : end.hour.toString()) +
        ":" +
        (end.minute < 10 ? "0" + end.minute.toString() : end.minute.toString());
  }
}
