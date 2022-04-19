import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:sol_connect/core/api/models/timegrid.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/rpcresponse.dart';
import 'package:sol_connect/core/api/timetable.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/exceptions.dart';

class TimetableManager {
  DateTime? nextBlockStart;
  DateTime? nextBlockEnd;

  UserSession userSession;
  var frames = <TimetableFrame>[];
  Timegrid? _timegrid = Timegrid.timegridFallback;

  TimetableManager(this.userSession, [Timegrid? timegrid]) {
    if (timegrid != null) {
      _timegrid = timegrid;
    }
  }

  void clearFrameCache({bool hardReset = false}) {
    nextBlockStart = null;
    nextBlockEnd = null;
    
    if (hardReset) {
      frames.clear();
      return;
    }

    for (TimetableFrame frame in frames) {
      frame._cachedWeekData = null;
    }
  }

  //Wochen sind sortiert
  Future<List<TimetableFrame>> getNextBlockWeeks() async {
    await getNextBlockStart();
    await getNextBlockEnd();
    //Durch die obigen Funktionen ist zwangsmäßig der Block ausgemappt. Und der Cache mit allen nötigen Frames gefüllt.
    //Jetzt nut noch abtesten welche Frames sich innerhalb der Daten befinden

    var blockWeeks = <TimetableFrame>[];

    for (TimetableFrame frame in frames) {
      if (frame._frameStart.millisecondsSinceEpoch >= nextBlockStart!.millisecondsSinceEpoch &&
          frame._frameEnd.millisecondsSinceEpoch <= nextBlockEnd!.millisecondsSinceEpoch) {
        blockWeeks.add(frame);
      }
    }

    //Sortiere die Blockwochen
    blockWeeks.sort((a, b) => a._frameStart.millisecondsSinceEpoch.compareTo(b._frameStart.millisecondsSinceEpoch));
    return blockWeeks;
  }

  //Der Blockstart des aktuellen Datums
  Future<DateTime> getNextBlockStart() async {
    if (nextBlockStart != null) {
      return nextBlockStart!;
    } else {
      if (!(await getFrameRelativeToCurrent(0).getWeekData()).isNonSchoolblockWeek()) {
        //Aktuelle Woche ist eine Schulwoche. Suche in der Vergangenheit
        for (int i = 0; i >= -5; i--) {
          TimetableFrame frame = getFrameRelativeToCurrent(i);
          if ((await frame.getWeekData()).isNonSchoolblockWeek()) {
            nextBlockStart = frame._frameEnd;
            return nextBlockStart!;
          }
        }
      } else {
        //Aktuelle Woche ist keine Schulwoche. Suche in der Zukunft
        for (int i = 0; i < 5; i++) {
          TimetableFrame frame = getFrameRelativeToCurrent(i);
          if (!(await frame.getWeekData()).isNonSchoolblockWeek()) {
            nextBlockStart = frame._frameStart;
            return nextBlockStart!;
          }
        }
      }
    }
    throw NextBlockStartNotInRangeException("Kann nächsten Block start (noch) nicht feststellen");
  }

  Future<DateTime> getNextBlockEnd() async {
    if (nextBlockEnd != null) {
      return nextBlockEnd!;
    } else {
      //Hier wird nur in der zukunft gesucht.

      //Aktuelle Woche ist eine Schulwoche. Suche bis eine nicht Schulwoche kommt
      if (!(await getFrameRelativeToCurrent(0).getWeekData()).isNonSchoolblockWeek()) {
        for (int i = 0; i < 5; i++) {
          TimetableFrame frame = getFrameRelativeToCurrent(i);
          if ((await frame.getWeekData()).isNonSchoolblockWeek()) {
            nextBlockEnd = frame._frameStart;
            return nextBlockEnd!;
          }
        }
      } else {
        //Aktuelle Woche ist keine Schulwoche. Suche bis "wieder" keine Schulwoche kommt nachdem schulwochen gefunden wurden
        bool weekFound = false;
        for (int i = 0; i < 10; i++) {
          TimetableFrame frame = getFrameRelativeToCurrent(i);
          if (!(await frame.getWeekData()).isNonSchoolblockWeek()) {
            weekFound = true;
          }
          if ((await frame.getWeekData()).isNonSchoolblockWeek() && weekFound) {
            nextBlockEnd = frame._frameStart;
            return nextBlockEnd!;
          }
        }
      }
    }
    throw NextBlockEndNotInRangeException("Konnte nächsten Blockende nicht ausfindig machen");
  }

  ///Gibt nur das Datum einers Wochenstartes relativ zum aktuellen Datum zurück ohne ein extra Timetable Objekt abzufragen und zu erzeugen
  DateTime _getRelativeWeekStartDate(int relative) {
    DateTime from = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    if (relative < 0) {
      //Ziehe die duration ab und gehe in die Vergangenheit
      from = from.subtract(Duration(days: DateTime.daysPerWeek * relative.abs()));
    } else if (relative > 0) {
      //Addiere die Duration und gehe in die Zukunft.
      from = from.add(Duration(days: DateTime.daysPerWeek * relative));
    }
    return from;
  }

  TimetableFrame? _getCachedFrame(DateTime from, DateTime to) {
    for (TimetableFrame frame in frames) {
      if (Utils.dayMatch(frame._frameStart, from) && Utils.dayMatch(frame._frameEnd, to)) {
        return frame;
      }
    }
    return null;
  }

  // TODO(philipp): Fertig machen
  /*TimetableFrame getFramefromRange(DateTime startDate, DateTime endDate) {
    
    for(TimetableFrame frame in frames) {
      if(frame._frameStart.millisecondsSinceEpoch <= startDate.millisecondsSinceEpoch && 
        frame._frameEnd.millisecondsSinceEpoch >= endDate.millisecondsSinceEpoch) {
          return frame;
      }
    }

  }*/

  //void modifyFrameCache(TimeTableRange rng, TimetableFrame frame) {
  //  frame._cachedWeekData = rng;
  //}

  TimetableFrame getFrameRelativeToCurrent(int relative, {bool locked = false}) {
    DateTime from = _getRelativeWeekStartDate(relative);
    from = Utils.normalizeDate(from);
    DateTime lastDayOfWeek = from.add(Duration(days: DateTime.daysPerWeek - from.weekday + 1));
    lastDayOfWeek = Utils.normalizeDate(lastDayOfWeek);

    //Checke ob der Frame schon existiert
    TimetableFrame? cached = _getCachedFrame(from, lastDayOfWeek);
    if (cached == null) {
      TimetableFrame newFrame = TimetableFrame(from, lastDayOfWeek, relative, this, userSession);
      frames.add(newFrame);
      return newFrame;
    } else {
      return cached;
    }
  }

  Timegrid get timegrid => _timegrid!;

  void setTimegrid(Timegrid timegrid) {
    _timegrid = timegrid;
  }
}

///Ein timetable frame ist immer im cache und beinhaltet Persistente Informationen die
///sich über eine Instanz nicht verändern.
///Dazu zählen:
///* Block Start - End Informationen
///* Wochen Start - und End Informationen
///* Index der Woche im aktuellen Block
class TimetableFrame {
  final DateTime _frameStart;
  final DateTime _frameEnd;

  int _blockIndex = -1;
  int _relativeToCurrentWeek = 0;

  final TimetableManager _mgr;
  final UserSession _activeSession;

  TimeTableRange? _cachedWeekData;

  TimetableFrame(this._frameStart, this._frameEnd, int relative, this._mgr, this._activeSession) {
    _relativeToCurrentWeek = relative;
  }

  DateTime getFrameStart() {
    return _frameStart;
  }

  DateTime getFrameEnd() {
    return _frameEnd;
  }

  int getRelativeToCurrentWeek() {
    return _relativeToCurrentWeek;
  }

  TimetableManager getManager() {
    return _mgr;
  }

  Future<TimeTableRange> getWeekData(
      {bool reload = false, int personId = -1, PersonTypes personType = PersonTypes.unknown}) async {
    if (!reload && _cachedWeekData != null) {
      return _cachedWeekData!;
    }

    if (_activeSession.isDemoSession) {
      await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 200));

      if (_relativeToCurrentWeek == 1) {
        String timetabledata = await rootBundle.loadString('assets/demo/timetables/timetable1.json');
        return TimeTableRange(getFrameStart(), getFrameEnd(), this, RPCResponse.handleArtifical(timetabledata));
      } else if (_relativeToCurrentWeek == 0) {
        String timetabledata = await rootBundle.loadString('assets/demo/timetables/timetable2.json');
        return TimeTableRange(getFrameStart(), getFrameEnd(), this, RPCResponse.handleArtifical(timetabledata));
      } else {
        String timetabledata = await rootBundle.loadString('assets/demo/timetables/empty-timetable.json');
        return TimeTableRange(getFrameStart(), getFrameEnd(), this, RPCResponse.handleArtifical(timetabledata));
      }
    }

    TimeTableRange rng =
        await _activeSession.getTimeTable(_frameStart, _frameEnd, this, personId: personId, personType: personType);
    _cachedWeekData = rng;

    return rng;
  }

  ///Gibt den index zurück, in welcher Woche die Aktuelle range ist seitdem der neue Block gestartet ist.
  ///Schwere operation. Es wird empfolen diese Funktion nur aufzurufen wenn es wirklich sein muss
  Future<int> getCurrentBlockWeek({bool concurrentSave = false}) async {
    if (_blockIndex >= 0) return _blockIndex;

    //MAXIMAL 5 Wochen zurück
    int steps = -1;
    for (int i = _relativeToCurrentWeek; i >= -5; i--, steps++) {
      TimeTableRange week = await _mgr.getFrameRelativeToCurrent(i, locked: concurrentSave).getWeekData();
      if (week.isNonSchoolblockWeek()) {
        _blockIndex = steps;
        return _blockIndex;
      }
    }
    _blockIndex = -1;
    return _blockIndex;
  }
}
