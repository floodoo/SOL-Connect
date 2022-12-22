/*Author Philipp Gersch */
import 'package:sol_connect/core/api/models/timetable.hour.dart';
import 'package:sol_connect/core/api/timetable.dart';
import 'package:sol_connect/core/excel/models/mappedsheet.dart';
import 'package:sol_connect/core/excel/validator.dart';

class MergedTimeTable {

  //Der Stundenplan
  final TimeTableRange timetable;

  //Die phasen zum Stundenplan
  final MappedSheet? mapped;

  MergedTimeTable(this.timetable, this.mapped);

  ///Gibt `true` zurück, wenn der gebundene Stundenplan `timetable` erfolgreich in `mapped` gemappt wurde.
  ///
  ///Wenn dies nicht der Fall ist, ist `mapped` null. Außerdem kann eine kurze Fehlernachricht in `MergedTimeTable.errorMessage` ausgelesen werden.
  bool verified() {
    if (mapped != null) {
      return mapped!.isValid();
    } else {
      return false;
    }
  }

  ///Gibt die entsprechende Phasierung zum Stunden Index zurück.
  ///
  ///* `getPhaseFromHourIndex(xIndex: 0, yIndex: 0)`  gibt die Phasierung zur ersten Stunde am Montag zurück
  ///* `getPhaseFromHourIndex(xIndex: 2, yIndex: 2)` gibt die Phasierung zur dritten Stunde am Mittwoch zurück
  ///
  ///Gibt immer unbekannte Phasen zurück, wenn `verified() == false`
  MappedPhase getPhaseFromHourIndex({int xIndex = 0, int yIndex = 0}) {
    return getPhaseForHour(timetable.getHourByIndex(xIndex: xIndex, yIndex: yIndex));
  }

  ///Gibt die entsprechende Phasierung zum Stundenobjekt zurück
  ///
  ///Gibt immer unbekannte Phasen zurück, wenn `verified() == false`
  MappedPhase getPhaseForHour(TimeTableHour hour) {
    for (MappedPhase phase in mapped!.getHours()) {
      if (phase.getHourXIndex() == hour.xIndex && phase.getHourYIndex() == hour.yIndex) {
        return phase;
      }
    }
    return MappedPhase();
  }
}
