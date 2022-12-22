import 'package:sol_connect/core/excel/models/mergedtimetable.dart';

///Anders als "mergedTimetable" beinhaltet diese Klasse einen kompletten Block, nicht nur eine Woche
class MergedBlock {
  
  final _hours = <MergedTimeTable>[];
  
  final DateTime _blockStart;
  final DateTime _blockEnd;

  MergedBlock(this._blockStart, this._blockEnd, List<MergedTimeTable> weeks) {
    for (MergedTimeTable week in weeks) {
      _hours.add(week); //TODO @DevKevYT further checks for valid weeks
    }
  }

  DateTime get blockStart => _blockStart;
  
  DateTime get blockEnd => _blockEnd;

}
