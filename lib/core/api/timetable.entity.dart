/**Kleiner Wrapper für mehr Lesbarkeit */
class TimeTableEntity {
  String typeName = "";
  String name = "";
  String longName = "";
  int identifier = -1;

  TimeTableEntity(String typeName, dynamic data) {
    if (data == null) return;

    this.typeName = typeName;
    this.name = data[0]['name'].toString();
    this.longName = data[0]['longname'];
    this.identifier = data[0]['id'];
  }
}
