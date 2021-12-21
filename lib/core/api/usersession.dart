import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rpcresponse.dart' as rh;
import 'utils.dart' as utils;
import 'timetable.range.dart';

class UserSession {
  static const types = {
    'CLASS': 1,
    'TEACHER': 2,
    'SUBJECT': 3,
    'ROOM': 4,
    'STUDENT': 5
  };

  String applicationName = "default";
  String sessionId = "";
  int personId = -1;
  int klasseId = -1;
  int type = 0;

  String school = "";
  String schoolBase64 = "";

  String URL = "https://hepta.webuntis.com/WebUntis/jsonrpc.do?school=";
  bool sessionValid = false;

  UserSession(String school, String appID) {
    applicationName = appID;

    this.school = school;
    this.schoolBase64 = base64Encode(utf8.encode(this.school));
    URL += this.school.toString();
  }

  /**Diese müssen in den Header gelegt werden */
  String buildAuthCookie() {
    if (!sessionValid) return "";

    return "JSESSIONID=" +
        sessionId +
        "; schoolname=" +
        schoolBase64.replaceAll("=", "%3D");
  }

  Future createSession(username, password) async {
    rh.RPCResponse response = await query({
      "id": applicationName,
      "method": "authenticate",
      "params": {
        "user": username,
        "password": password,
        "client": applicationName
      },
      "jsonrpc": 2.0
    });

    //TODO bessere error Nachrichten vorallem bei bekannen Error codes
    if (response.isHttpError())
      throw Exception("Ein http Fehler ist aufegteten: " +
          response.errorMessage.toString() +
          "(" +
          response.errorCode.toString() +
          ")");
    else if (response.isError()) {
      if (response.errorCode == -8504) {
        throw Exception("Benutzename oder Passwort falsch");
      } else
        throw new Exception("Ein Fehler ist aufgetreten: " +
            response.errorMessage.toString() +
            "(" +
            response.errorCode.toString() +
            ")");
    }

    sessionId = response.payload['sessionId'];
    personId = response.payload['personId'];
    klasseId = response.payload['klasseId'];
    type = response.payload['personType'];

    sessionValid = true;

    print("Login Successfull");
  }

  Future<TimeTableRange> getTimeTable(DateTime from, DateTime to) async {
    if (!sessionValid) throw Exception("Die Session ist ungültig.");

    return TimeTableRange(await query({
      "id": applicationName,
      "method": "getTimetable",
      "params": {
        "options": {
          "startDate": utils.convertToUntisDate(from),
          "endDate": utils.convertToUntisDate(to),
          "element": {"id": this.personId, "type": this.type},
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

  Future<rh.RPCResponse> query(Object data) async {
    return rh.RPCResponse.handle(await http.Client().post(Uri.parse(URL),
        headers: {
          'Content-type': 'application/json',
          'Cookie': buildAuthCookie()
        },
        body: jsonEncode(data)));
  }
}
