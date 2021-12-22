import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rpcresponse.dart' as rh;
import 'models/utils.dart' as utils;
import 'timetable.dart';

class UserSession {
  static const types = {'CLASS': 1, 'TEACHER': 2, 'SUBJECT': 3, 'ROOM': 4, 'STUDENT': 5};

  String applicationName = "default";
  String sessionId = "";
  int personId = -1;
  int klasseId = -1;
  int type = 0;

  String school = "";
  String schoolBase64 = "";

  // ignore: non_constant_identifier_names
  String URL = "https://hepta.webuntis.com/WebUntis/jsonrpc.do?school=";
  bool sessionValid = false;

  // ignore: unused_field
  String _un = "";
  // ignore: unused_field
  String _pwd = "";

  UserSession(String school, String appID) {
    applicationName = appID;

    schoolBase64 = base64Encode(utf8.encode(school));
    URL += school.toString();
  }

  ///Erstellt eine User Session. Gibt nur ein Future Objekt zurück, welches ausgeführt wird, wenn die Server Antwort kommt
  Future createSession({String username = "", String password = ""}) async {
    if(username == "" || password == "") throw Exception("Bitte gib einen Benutzenamen und ein Passwort an");
    rh.RPCResponse response = await _query({
      "id": applicationName,
      "method": "authenticate",
      "params": {"user": username, "password": password, "client": applicationName},
      "jsonrpc": 2.0
    });

    if (response.isHttpError()) {
      throw Exception("Ein http Fehler ist aufegteten: " +
          response.errorMessage.toString() +
          "(" +
          response.errorCode.toString() +
          ")");
    } else if (response.isError()) {
      if (response.errorCode == -8504) {
        throw Exception("Benutzename oder Passwort falsch");
      } else {
        throw Exception("Ein Fehler ist aufgetreten: " +
            response.errorMessage.toString() +
            "(" +
            response.errorCode.toString() +
            ")");
      }
    }

    sessionId = response.payload['sessionId'];
    personId = response.payload['personId'];
    klasseId = response.payload['klasseId'];
    type = response.payload['personType'];

    sessionValid = true;
    _un = username;
    _pwd = password;

  }

  Future<TimeTableRange> getTimeTableForThisWeek() async {
    DateTime firstDayOfTheweek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    DateTime lastDayOfWeek =
        firstDayOfTheweek.add(Duration(days: DateTime.daysPerWeek - firstDayOfTheweek.weekday + 1));
    return getTimeTable(firstDayOfTheweek, lastDayOfWeek);
  }

  Future<TimeTableRange> getTimeTableForToday() async {
    if (!sessionValid) throw Exception("Die Session ist ungültig.");

    return getTimeTable(DateTime.now(), DateTime.now());
  }

  Future<TimeTableRange> getTimeTable(DateTime from, DateTime to) async {
    if (!sessionValid) throw Exception("Die Session ist ungültig.");

    return TimeTableRange(
        from,
        to,
        await _query({
          "id": applicationName,
          "method": "getTimetable",
          "params": {
            "options": {
              "startDate": utils.convertToUntisDate(from),
              "endDate": utils.convertToUntisDate(to),
              "element": {"id": personId, "type": type},
              "showLsText": true,
              "showStudentgroup": true,
              "showLsNumber": true,
              "showSubstText": true,
              "showInfo": true,
              "showBooking": true,
              "klasseFields": ['id', 'name', 'longname', 'externalkey'],
              "roomFields": ['id', 'name', 'longname', 'externalkey'],
              "subjectFields": ['id', 'name', 'longname', 'externalkey'],
              "teacherFields": ['id', 'name', 'longname', 'externalkey']
            }
          },
          "jsonrpc": 2.0
        }));
  }

  Future<rh.RPCResponse> _query(Object data) async {
    return rh.RPCResponse.handle(await http.Client().post(Uri.parse(URL),
        headers: {'Content-type': 'application/json', 'Cookie': _buildAuthCookie()}, body: jsonEncode(data)));
  }

  /// Diese müssen in den Header gelegt werden
  String _buildAuthCookie() {
    if (!sessionValid) return "";

    return "JSESSIONID=" + sessionId + "; schoolname=" + schoolBase64.replaceAll("=", "%3D");
  }
}
