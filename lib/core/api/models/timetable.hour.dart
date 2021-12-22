import 'timetable.entity.dart';

class TimeTableHour {
  TimeTableEntity _klasse = TimeTableEntity("", null);
  TimeTableEntity _teacher = TimeTableEntity("", null);
  TimeTableEntity _subject = TimeTableEntity("", null);
  TimeTableEntity _room = TimeTableEntity("", null);

  String _activityType = "";
  int _id = -1;
  DateTime start = DateTime(0);
  DateTime end = DateTime(0);

  String code = "regular";

  DateTime _parseDate(String date, String time) {
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

  String getActivityType() {
    return _activityType;
  }

  int getId() {
    return _id;
  }

  DateTime getStartTime() {
    return start;
  }

  DateTime getEndTime() {
    return end;
  }

  TimeTableEntity getClazz() {
    return _klasse;
  }

  TimeTableEntity getTeacher() {
    return _teacher;
  }

  TimeTableEntity getSubject() {
    return _subject;
  }

  TimeTableEntity getRoom() {
    return _room;
  }

  TimeTableHour(dynamic data) {
    this._id = data['id'];

    this.start = _parseDate(data['date'].toString(), data['startTime'].toString());
    this.end = _parseDate(data['date'].toString(), data['endTime'].toString());

    this._activityType = data['activityType'];

    this._klasse = new TimeTableEntity("kl", data['kl']);
    this._teacher = new TimeTableEntity("te", data['te']);
    this._subject = new TimeTableEntity("su", data['su']);
    this._room = new TimeTableEntity("ro", data['ro']);

    if (data['code'] != null) {
      this.code = data['code'];
    }
  }

  ///Der Titel der Stunde. Im Format HH:mm - HH:mm
  String getTitle() {
    return (start.hour < 10 ? "0" + start.hour.toString() : start.hour.toString()) +
        ":" +
        (start.minute < 10 ? "0" + start.minute.toString() : start.minute.toString()) +
        " - " +
        (end.hour < 10 ? "0" + end.hour.toString() : end.hour.toString()) +
        ":" +
        (end.minute < 10 ? "0" + end.minute.toString() : end.minute.toString());
  }
}
