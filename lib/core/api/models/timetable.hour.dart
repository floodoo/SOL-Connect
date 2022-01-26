/*Author Philipp Gersch */
import 'package:sol_connect/core/api/models/timegrid.dart';
import 'package:sol_connect/core/api/models/timetable.entity.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/timetable.dart';

enum Codes {
  //untis given
  regular,
  irregular,
  cancelled,
  empty,
  unknown,

  //custom
  noteacher
}

extension CodeReadables on Codes {
  String get readableName {
    switch (this) {
      case Codes.cancelled:
        return "Entfall";
      case Codes.regular:
        return "Regulär";
      case Codes.irregular:
        return "Vertretung";
      case Codes.empty:
        return "Unbekannt";
      case Codes.noteacher:
        return "Lehrer Entfall";
      default:
        return "Unbekannt";
    }
  }
}

class TimeTableHour {
  static const noTeacherDisplayname = "---";

  TimeTableEntity _klasse = TimeTableEntity("", null);
  TimeTableEntity _teacher = TimeTableEntity("", null);
  TimeTableEntity _subject = TimeTableEntity("", null);
  TimeTableEntity _room = TimeTableEntity("", null);

  final replacement = <TimeTableHour>[];

  String _substText = "";
  String _activityType = "";
  int _id = -1;

  String startAsString = "0000";
  DateTime start = DateTime(0);
  String endAsString = "0000";
  DateTime end = DateTime(0);

  Codes _code = Codes.unknown;

  ///Index der X-Koordinate wenn die Stunde auf einem Gridartigem Stundenplan liegt.
  ///* xIndex=0, yIndex=0 wäre Montag erste Stunde
  ///* xIndex=1,yIndex=2 wäre Dienstag 3. Stunde
  int xIndex = -1;

  ///Index der Y-Koordinate wenn die Stunde auf einem Gridartigem Stundenplan liegt
  ///* xIndex=0, yIndex=0 wäre Montag erste Stunde
  ///* xIndex=1,yIndex=2 wäre Dienstag 3. Stunde
  int _yIndex = -1;

  ///Stundenindex. Ähnlich wie yIndex wird jedoch bei der Inizialisierung gesetzt und ist nicht abhängig von der fertigen Tabelle
  int _hourIndex = -1;

  final TimeTableRange _rng;

  TimeTableHour(dynamic data, this._rng) {
    if (data == null) {
      _code = Codes.empty;
      return;
    }

    _id = data['id'];

    startAsString = data['startTime'].toString();
    endAsString = data['endTime'].toString();

    start = _parseDate(data['date'].toString(), startAsString);
    end = _parseDate(data['date'].toString(), endAsString);

    _activityType = data['activityType'];

    if (data['k1'] != null) {
      _klasse = TimeTableEntity("kl", data['kl']);
    } else {
      _klasse = TimeTableEntity("kl", null);
      _klasse.longName = "unknown";
      _klasse.name = "unknown";
    }

    if (data['te'] != null) {
      _teacher = TimeTableEntity("te", data['te']);
    } else {
      _teacher.name = noTeacherDisplayname;
      _teacher.longName = "Kein Lehrer";
    }

    _subject = TimeTableEntity("su", data['su']);

    _room = TimeTableEntity("ro", data['ro']);

    if (data['code'] != null) {
      String c = data['code'];

      if (c == "regular") {
        //Ziele den speziellen case "Lehrer entfall" nur in Betracht, wenn sonst kein anderer code speziell angegeben sind"
        if (!hasTeacher()) {
          _code = Codes.noteacher;
        } else {
          _code = Codes.regular;
        }
      } else if (c == "cancelled") {
        _code = Codes.cancelled;
      } else if (c == "irregular") {
        _code = Codes.irregular;
      } else {
        _code = Codes.unknown;
      }
    } else {
      if (!hasTeacher()) {
        _code = Codes.noteacher;
      } else {
        _code = Codes.regular;
      }
    }

    if (data['substText'] != null) {
      _substText = data['substText'];
    }

    for (int i = 0; i < _rng.getBoundFrame().getManager().timegrid.entries.length; i++) {
      if (startAsString == _rng.getBoundFrame().getManager().timegrid.getEntryByYIndex(yIndex: i).startTime) {
        _hourIndex = i;
        break;
      }
    }
  }

  //Ändert das Datim dieser Stunde. Stunde und Minute dürfen nicht verändert werden
  void modifyDate(int year, int month, int day) {
    int startHour = start.hour;
    int startMinute = start.minute;
    start = DateTime(year, month, day, startHour, startMinute);

    int endHour = end.hour;
    int endMinute = end.minute;
    start = DateTime(year, month, day, endHour, endMinute);
  }

  void setYIndex({int yIndex = -1}) {
    _yIndex = yIndex;
    TimegridEntry grid = _rng.getBoundFrame().getManager().timegrid.getEntryByYIndex(yIndex: _yIndex);

    startAsString = grid.startTime;
    endAsString = grid.endTime;
    start = _parseDate(Utils().convertToUntisDate(start), startAsString);
    end = _parseDate(Utils().convertToUntisDate(end), endAsString);
  }

  int get yIndex => _yIndex;

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

  ///Gibt den Index der Stunde zurück. Abhängig von der Startzeit der Stunde, nicht von der fertigen Tabelle
  int getHourIndex() {
    return _hourIndex;
  }

  bool hasTeacher() {
    return _teacher.name != noTeacherDisplayname;
  }

  ///Gibt die Stundeninformation zurück, die ein Lehere bei Ausfall vielleicht notiert hat.
  ///
  ///Meißtenst steht dann "EvA" da
  String getLessionInformation() {
    return _substText;
  }

  String getActivityType() {
    return _activityType;
  }

  ///Der Code beschreibt die "Art" der Stunde. Folgende Codes sind definiert als:
  ///* __regular__: Die Stunde ist regulär
  ///* __irregular__: Die Stunde ist nicht standartmäßig vorgesehen. Sie kam durch einen Ausfall zustande. Die Liste "getReplacement()" gibt die Stunde zurück, die diese ersetzen soll.
  ///* __cancelled__: Die Stunde fällt aus
  ///* __empty__: Die Stunde gibt es nicht. Diese dient also nur als Platzhalter um Lücken zu füllen falls z.B. die Erste Stunde frei ist
  ///* __unknown__: Das sollte nicht vorkommen. Der Status ist unbekannt / illegal
  Codes getLessonCode() {
    return _code;
  }

  ///Wenn `true` dann besitzt die Stunde in `getReplacement()` eine Stunde die diese durch eine Vertretung ersetzen soll.
  bool isIrregular() {
    return getLessonCode() == Codes.irregular;
  }

  ///Diese Stunde ist leer bzw. es gibt hier nichts
  bool isEmpty() {
    return getLessonCode() == Codes.empty;
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

  ///Gibt die Stunden zurück die diese ersetzen sollen.
  ///Ist nicht leer wenn `getLessonCode()` -> `Code.irregular` zuückliefert.
  TimeTableHour getReplacement() {
    return replacement[0];
  }

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

  ///Interne Funktion.
  void addIrregularHour(TimeTableHour entity) {
    entity.xIndex = xIndex;
    entity._yIndex = _yIndex;
    entity._code = _code;
    replacement.add(entity);
  }

  ///Die Startzeit im Format HH:mm
  String getStartTimeString() {
    return start.hour.toString() + ":" + (start.minute >= 10 ? start.minute.toString() : start.minute.toString() + "0");
  }

  ///Die Endzeit im Format HH:mm
  String getEndTimeString() {
    return end.hour.toString() + ":" + (end.minute >= 10 ? end.minute.toString() : end.minute.toString() + "0");
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

  @override
  String toString() {
    return getSubject().name + " (" + getTeacher().name + ")" + " Code: " + getLessonCode().name;
  }
}
