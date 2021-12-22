///Kleiner Wrapper für mehr Lesbarkeit
class TimeTableEntity {
  String typeName = "";
  String name = "";
  String longName = "";
  int identifier = -1;

  TimeTableEntity(String typeName, dynamic data) {
    if (data == null) return;

    name = data[0]['name'].toString();
    longName = data[0]['longname'];
    identifier = data[0]['id'];
  }
}
