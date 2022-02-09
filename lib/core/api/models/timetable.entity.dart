/*Author Philipp Gersch */

class TimeTableEntity {
  String typeName = "";
  String name = "";
  String longName = "";
  int identifier = -1;

  TimeTableEntity(this.typeName, dynamic data) {
    if (data == null) return;
    if ((data as List<dynamic>).isNotEmpty) {
      name = data[0]['name'].toString();
      longName = data[0]['longname'];
      identifier = data[0]['id'];
    }
  }
}
