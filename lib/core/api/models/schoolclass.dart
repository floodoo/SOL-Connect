class SchoolClass {

  int _type = -1;
  int _id = -1;
  String _name = "";
  String _displayName = "";
  String _classTeacherName = "";
  String _classTeacherLongName = "";

  String _classTeacher2Name = "";
  String _classTeacher2LongName = "";

  SchoolClass(dynamic data) {
    if(data == null) {
      return;
    }

    _id = data["id"];
    _type = data["type"];
    _name = data["name"];
    _displayName = data["displayname"];

    if(data["classteacher"] != null) {
      _classTeacherName = data["classteacher"]["name"];
      _classTeacherLongName = data["classteacher"]["longName"];
    }

    if(data["classteacher2"] != null) {
      _classTeacher2Name = data["classteacher2"]["name"];
      _classTeacher2LongName = data["classteacher2"]["longName"];
    }
  }

  ///Üblicherweise 1: Klasse
  int get type => _type;

  ///Die ID der Klasse
  int get id => _id;

  ///Name der Klasse: BS FI 21A
  String get name => _name;

  ///Name wie er überall angezeigt werden kann: BS FI 21A
  String get displayName => _displayName;

  ///Kürzel des Klassenlehrers. Üblicherweise 3 Buchstaben in caps
  String get classTeacherName => _classTeacherName;

  ///Der Nachnahme des Lehrers
  String get classTeacherLongName => _classTeacherLongName;

  ///Kürzel des Klassenlehrers falls einer existiert. Üblicherweise 3 Buchstaben in caps
  String get classTeacher2Name => _classTeacher2Name;

  ///Der Nachnahme des 2. Klassenlehrers
  String get classTeacher2LongName => _classTeacher2LongName;
}