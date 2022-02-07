import 'package:sol_connect/core/api/models/utils.dart';

// TODO(philipp): Kommentieren
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
    _uploaded = DateTime.fromMillisecondsSinceEpoch(json['created']);
    _fileOwnerId = json['fileowner'];
  }

  DateTime get blockStart => _startDate;

  DateTime get blockEnd => _endDate;

  DateTime get fileCreated => _uploaded;

  int get fileOwnerId => _fileOwnerId;
}
