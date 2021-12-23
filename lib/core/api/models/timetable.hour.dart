import 'timetable.entity.dart';

enum Codes { regular, irregular, cancelled, empty, unknown }

class HourEntities {
  TimeTableEntity _klasse = TimeTableEntity("", null);
  TimeTableEntity _teacher = TimeTableEntity("", null);
  TimeTableEntity _subject = TimeTableEntity("", null);
  TimeTableEntity _room = TimeTableEntity("", null);

  ///@return Die Klasse der Stunde als TimeTableEntity objekt
  TimeTableEntity getClazz() {
    return _klasse;
  }

  ///@return Der Lehrer der Stunde als TimeTableEntity objekt
  TimeTableEntity getTeacher() {
    return _teacher;
  }

  ///@return Das Fach der Stunde als TimeTableEntity objekt
  TimeTableEntity getSubject() {
    return _subject;
  }

  ///@return Der Raum der Stunde als TimeTableEntity objekt
  TimeTableEntity getRoom() {
    return _room;
  }
}

class TimeTableHour {
  final entities = <HourEntities>[];

  String _activityType = "";
  int _id = -1;

  String startAsString = "0000";
  DateTime start = DateTime(0);
  String endAsString = "0000";
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

  Codes getLessonCode() {
    if (entities.isEmpty) {
      return Codes.empty;
    } else if (code == "regular") {
      return Codes.regular;
    } else if (code == "cancelled") {
      return Codes.cancelled;
    } else if (code == "irregular") {
      return Codes.irregular;
    }
    return Codes.unknown;
  }

  String getActivityType() {
    return _activityType;
  }

  bool isIrregular() {
    return getLessonCode() == Codes.irregular;
  }

  ///Diese Stunde ist leer bzw. es gibt hier nichts
  bool isEmpty() {
    return getLessonCode() == Codes.empty;
  }

  bool hasMultipleEntries() {
    return entities.length > 1;
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

  ///Wenn diese Stunde den Code IRREGULAR besitzt, ist es sehr warscheinlich dass sie mehrere Einträge besitzt.
  ///Z.B. Original Stunde und ersetzte Stunde
  ///Diese Funktion gibt alle einräge als "HourEntities" Objekt Liste zurück.
  List<HourEntities> getIrregularHours() {
    return entities;
  }

  ///@return Die Klasse der Stunde als TimeTableEntity objekt
  TimeTableEntity getClazz() {
    if (isEmpty()) return TimeTableEntity("empty", null);
    return entities[0].getClazz();
  }

  ///@return Der Lehrer der Stunde als TimeTableEntity objekt
  TimeTableEntity getTeacher() {
    if (isEmpty()) return TimeTableEntity("empty", null);
    return entities[0].getTeacher();
  }

  ///@return Das Fach der Stunde als TimeTableEntity objekt
  TimeTableEntity getSubject() {
    if (isEmpty()) return TimeTableEntity("empty", null);
    return entities[0].getSubject();
  }

  ///@return Der Raum der Stunde als TimeTableEntity objekt
  TimeTableEntity getRoom() {
    if (isEmpty()) return TimeTableEntity("empty", null);
    return entities[0].getRoom();
  }

  TimeTableHour(dynamic data) {
    if (data == null) {
      return;
    }

    _id = data['id'];

    startAsString = data['startTime'].toString();
    endAsString = data['endTime'].toString();

    start = _parseDate(data['date'].toString(), startAsString);
    end = _parseDate(data['date'].toString(), endAsString);

    _activityType = data['activityType'];

    HourEntities entity = HourEntities();

    if (data['k1'] != null) {
      entity._klasse = TimeTableEntity("kl", data['kl']);
    } else {
      entity._klasse = TimeTableEntity("kl", null);
      entity._klasse.longName = "unknown";
      entity._klasse.name = "unknown";
    }

    if (data['te'] != null) {
      entity._teacher = TimeTableEntity("te", data['te']);
    } else {
      entity._teacher.name = "---";
      entity._teacher.longName = "Ausfall/SOL/Vertretung";
    }

    entity._subject = TimeTableEntity("su", data['su']);

    entity._room = TimeTableEntity("ro", data['ro']);

    if (data['code'] != null) {
      code = data['code'];
    }

    entities.add(entity);
  }

  ///Interne Funktion.
  void addEntity(TimeTableHour entity) {
    entities.addAll(entity.entities);
  }

  ///@return Die Startzeit im Format HH:mm
  String getStatTimeString() {
    return start.hour.toString() + ":" + start.minute.toString();
  }

  ///@return Die Endzeit im Format HH:mm
  String getEndTimeString() {
    return end.hour.toString() + ":" + end.minute.toString();
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
