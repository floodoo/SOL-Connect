import 'package:sol_connect/core/api/models/utils.dart';

class PhaseStatus {
  DateTime _startDate = DateTime(0);
  DateTime _endDate = DateTime(0);
  DateTime _uploaded = DateTime(0);
  int _fileOwnerId = 0;

  PhaseStatus(dynamic json) {
    if (json == null) {
      return;
    }

    _startDate = Utils.convertToDateTime(json['startDate'].toString());
    _endDate = Utils.convertToDateTime(json['endDate'].toString());
    _uploaded = DateTime.fromMillisecondsSinceEpoch(((json['created'] as int) * 1000).round());
    _fileOwnerId = json['fileowner'];
  }

  ///Start des Blocks wie beim upload der Phasierungsdatei angegeben
  DateTime get blockStart => _startDate;

  ///Ende des Blocks wie beim upload der Phasierungsdatei angegeben (Der erste Montag nach dem Block)
  DateTime get blockEnd => _endDate;

  ///Wann das letzte mal die Datei hochgeladen wurde bzw aktualisiert wurde
  DateTime get fileCreated => _uploaded;

  ///Von wem die Datei das letzte mal hochgeladen wurde. Lässt sich mit "fileCreated" verbinden. (X hat am Y die Phasierung aktualisiert / geändert)
  int get fileOwnerId => _fileOwnerId;
}
