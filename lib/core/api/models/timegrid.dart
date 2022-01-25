class TimegridEntry {
  int _yIndex = -1;
  String _startTime = "0000";
  String _endTime = "0000";

  TimegridEntry(dynamic data) {
    if (data == null) {
      return;
    }

    _yIndex = data['unitOfDay'] - 1;
    _startTime = data['startTime'].toString();
    _endTime = data['endTime'].toString();
  }

  int get yIndex => _yIndex;

  String get startTime => _startTime.toString();

  String get endTime => _endTime.toString();
}

class Timegrid {
  int _schoolyearId = -1;
  final _entries = <TimegridEntry>[];

  final _fallback = TimegridEntry({"unitOfDay": -1, "startTime": "0000", "endTime": "0000"});

  Timegrid(dynamic data) {
    if (data == null) {
      return;
    }

    _schoolyearId = data['schoolyearId'];

    for (dynamic entry in data['units']) {
      _entries.add(TimegridEntry(entry));
    }
  }

  TimegridEntry getEntryByYIndex({int yIndex = 0}) {
    for (TimegridEntry entry in _entries) {
      if (entry.yIndex == yIndex) {
        return entry;
      }
    }
    return _fallback;
  }

  ///Alle Zeiten als Liste bestehend aus dem Typ `TimegridEntry`
  List<TimegridEntry> get entries => _entries;

  ///Die ID des aktuellen Schuljahres
  int get schoolYearId => _schoolyearId;

  //Ein fallback zu standartwerten, die sich aber von den aktuellen unterscheiden könnten. Betonung liegt auf "könnten"
  static Timegrid timegridFallback = Timegrid({
    "schoolyearId": 7,
    "units": [
      {"unitOfDay": 1, "startTime": "800", "endTime": "845"},
      {"unitOfDay": 2, "startTime": 845, "endTime": 930},
      {"unitOfDay": 3, "startTime": 945, "endTime": 1030},
      {"unitOfDay": 4, "startTime": 1030, "endTime": 1115},
      {"unitOfDay": 5, "startTime": 1130, "endTime": 1215},
      {"unitOfDay": 6, "startTime": 1215, "endTime": 1300},
      {"unitOfDay": 7, "startTime": 1330, "endTime": 1415},
      {"unitOfDay": 8, "startTime": 1415, "endTime": 1500},
      {"unitOfDay": 9, "startTime": 1515, "endTime": 1600},
      {"unitOfDay": 10, "startTime": 1600, "endTime": 1645},
      {"unitOfDay": 11, "startTime": 1730, "endTime": 1815},
      {"unitOfDay": 12, "startTime": 1815, "endTime": 1900},
      {"unitOfDay": 13, "startTime": 1900, "endTime": 1945},
      {"unitOfDay": 14, "startTime": 2000, "endTime": 2045},
      {"unitOfDay": 15, "startTime": 2045, "endTime": 2100}
    ]
  });
}
