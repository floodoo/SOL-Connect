import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rpcresponse.dart' as rh;
import 'models/utils.dart' as utils;
import 'timetable.dart';

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

  // ignore: non_constant_identifier_names
  String URL = "https://hepta.webuntis.com/WebUntis/jsonrpc.do?school=";
  bool sessionValid = false;

  // ignore: unused_field
  String _un = "";
  // ignore: unused_field
  String _pwd = "";

  UserSession({String school = "", String appID = ""}) {
    applicationName = appID;

    schoolBase64 = base64Encode(utf8.encode(school));
    URL += school.toString();
  }

  ///Erstellt eine User Session. Gibt nur ein Future Objekt zurück, welches ausgeführt wird, wenn die Server Antwort kommt
  Future createSession({String username = "", String password = ""}) async {
    if (username == "" || password == "") {
      throw Exception("Bitte gib einen Benutzenamen und ein Passwort an");
    }

    rh.RPCResponse response = await _query("authenticate",
        {"user": username, "password": password, "client": applicationName});

    if (response.isHttpError()) {
      throw Exception("Ein http Fehler ist aufegteten: " +
          response.getErrorMessage().toString() +  "(" + response.getErrorCode().toString() + ")");
    } else if (response.isError()) {
      if (response.getErrorCode() == -8504) {
        throw Exception("Benutzename oder Passwort falsch");
      } else {
        throw Exception("Ein Fehler ist aufgetreten: " + response.getErrorMessage().toString() + "(" + response.getErrorCode().toString() +  ")");
      }
    }

    sessionId = response.getPayloadData()['sessionId'];
    personId = response.getPayloadData()['personId'];
    klasseId = response.getPayloadData()['klasseId'];
    type = response.getPayloadData()['personType'];

    sessionValid = true;
    _un = username;
    _pwd = password;
  }

  ///Der Benutzername.
  String getUsername() {
    return _un;
  }

  ///Name der Schule wie sie in webuntis registriert ist
  String getSchool() {
    return school;
  }

  ///Die Rolle der eingeloggten Person. Es gibt "Schüler" und "Lehrer"
  String getPersonType() {
    if (type == 2) {
      return "Lehrer";
    } else if (type == 5) {
      return "Schüler";
    }
    return type.toString();
  }

  ///Loggt einen user aus und beendet die Session automatisch. Sie kann mit einem erneuten Login (createSession(...)) wieder aktiviert werden
  ///Wenn versucht wird nach dem ausloggen und vor einem wieder einloggen Daten zu holen wird der Fehler "Die Session ist ungültig" geworfen.*/
  Future<rh.RPCResponse> logout() async {
    rh.RPCResponse response =
        await _query("logout", {}, validateSession: false);
    sessionValid = false;
    sessionId = "";
    _un = "";
    _pwd = "";
    personId = -1;
    klasseId = -1;
    type = -1;
    return response;
  }

  ///Gibt einen Wochenstundenplan relativ zur derzeitigen Woche zurück. Von Montag bis Sonntag
  ///
  ///* Das heißt `getRelativeTimeTableWeek(-1);` gibt die vorherige Woche zur aktuellen zurück
  ///* `getRelativeTimeTableWeek(1);` gibt die nächste Woche zurück.
  ///* `getRelativeTimeTableWeek(0);` entspricht `getTimeTableForThisWeek()`
  Future<TimeTableRange> getRelativeTimeTableWeek(int relative) async {
    
    DateTime from = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    if (relative < 0) {
      //Ziehe die duration ab und gehe in die Vergangenheit
      from = from.subtract(Duration(days: DateTime.daysPerWeek * relative.abs()));
    } else if (relative > 0) {
      //Addiere die Duration und gehe in die Zukunft.
      from = from.add(Duration(days: DateTime.daysPerWeek * relative));
    }

    DateTime lastDayOfWeek = from.add(Duration(days: DateTime.daysPerWeek - from.weekday + 1));
    TimeTableRange rng = await getTimeTable(from, lastDayOfWeek);
    rng.relativeToCurrent = relative;
    return rng;
  }

  Future<TimeTableRange> getTimeTableForThisWeek() async {
    return getRelativeTimeTableWeek(0);
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
        this,
        await _query("getTimetable", {
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
        }));
  }

  /// Diese müssen in den Header gelegt werden
  String _buildAuthCookie() {
    if (!sessionValid) return "";

    return "JSESSIONID=" +
        sessionId +
        "; schoolname=" +
        schoolBase64.replaceAll("=", "%3D");
  }

  Future<rh.RPCResponse> _validateSession() async {
    return createSession(username: _un, password: _pwd).then((value) {
      if (value.isError()) {
        //Failed to login again.
        logout();
        throw Exception(
            "Refreshen der Session fehlgeschlagen. Hat sich das Passwort geändert?");
      }
      return value;
    });
  }

  Future<rh.RPCResponse> _query(String method, Object params,
      {bool validateSession = true}) async {
    Object build = {
      "id": applicationName,
      "method": method,
      "params": params,
      "jsonrpc": 2.0
    };

    rh.RPCResponse orig = rh.RPCResponse.handle(await http.Client().post(
        Uri.parse(URL),
        headers: {
          'Content-type': 'application/json',
          'Cookie': _buildAuthCookie()
        },
        body: jsonEncode(build)));

    if (validateSession && orig.getErrorCode() == -8520 && sessionValid) {
      rh.RPCResponse r = await _validateSession();
      if (!r.isError()) {
        return rh.RPCResponse.handle(await http.Client().post(Uri.parse(URL),
            headers: {
              'Content-type': 'application/json',
              'Cookie': _buildAuthCookie()
            },
            body: jsonEncode(build)));
      } else {
        return r;
      }
    } else {
      return orig;
    }
  }
}
