/*Author Philipp Gersch */
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:sol_connect/core/api/models/news.dart';
import 'package:sol_connect/core/api/models/profiledata.dart';
import 'package:sol_connect/core/api/models/schoolclass.dart';
import 'package:sol_connect/core/api/models/timegrid.dart';
import 'package:sol_connect/core/api/models/timetable.hour.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/rpcresponse.dart';
import 'package:sol_connect/core/api/timetable.dart';
import 'package:sol_connect/core/api/timetable_manager.dart';
import 'package:sol_connect/core/exceptions.dart';
import 'dart:convert';

import 'package:sol_connect/util/logger.util.dart';

enum PersonTypes { schoolClass, student, teacher, subject, room, unknown }

extension PersonTypeUtils on PersonTypes {
  static PersonTypes parse(int type) {
    switch (type) {
      case 1:
        return PersonTypes.schoolClass;
      case 2:
        return PersonTypes.teacher;
      case 3:
        return PersonTypes.subject;
      case 4:
        return PersonTypes.room;
      case 5:
        return PersonTypes.student;
      default:
        return PersonTypes.unknown;
    }
  }

  int get id {
    switch (this) {
      case PersonTypes.schoolClass:
        return 1;
      case PersonTypes.teacher:
        return 2;
      case PersonTypes.subject:
        return 3;
      case PersonTypes.room:
        return 4;
      case PersonTypes.student:
        return 5;
      default:
        return -1;
    }
  }

  String get readable {
    switch (this) {
      case PersonTypes.schoolClass:
        return "Klasse";
      case PersonTypes.teacher:
        return "Lehrer";
      case PersonTypes.subject:
        return "Fach";
      case PersonTypes.room:
        return "Raum";
      case PersonTypes.student:
        return "Schüler";
      default:
        return "";
    }
  }
}

class UserSession {
  final Logger log = getLogger();

  static const demoAccountName = "demo";
  bool _debugSession = false;

  String _appName = "adw8638ordfgq37qp98";
  String _sessionId = "";
  int _personId = -1;
  int _schoolClassId = -1;
  PersonTypes _type = PersonTypes.unknown;

  int _timetablePersonId = -1;
  PersonTypes _timetablePersonType = PersonTypes.unknown;

  String _school = "";
  String _schoolBase64 = "";

  ///Die base url von allen API Endpunkten.
  final String apiBaseUrl = "https://hepta.webuntis.com";

  ///JsonRPC endpoint. Überlicherweise: https://hepta.webuntis.com/WebUntis/jsonrpc.do?school=bbs1-mainz
  String rpcUrl = "";
  bool _sessionValid = false;

  // Empfindliche Variablen:

  // ignore: unused_field
  String _un = "";
  // ignore: unused_field
  String _pwd = "";
  //Token für API
  String _bearerToken = "";

  ProfileData _cachedProfileData = ProfileData(null);
  News _cachedNewsData = News(null);

  TimetableManager? _manager;
  Timegrid? _loadedTimegrid;

  UserSession({String school = "", String appID = ""}) {
    _appName = appID;

    _school = school;
    _schoolBase64 = base64Encode(utf8.encode(school));
    rpcUrl += apiBaseUrl + "/WebUntis/jsonrpc.do?school=" + school.toString();
  }

  ///Erstellt eine User Session. Gibt nur ein Future Objekt zurück, welches ausgeführt wird, wenn die Server Antwort kommt
  ///Kann folgende Exceptions werfen:
  ///
  ///* `MissingCredentialsException` Bei fehlendem Benutzer oder Passwort
  ///* `UserAlreadyLoggedInException` Wenn in dieser Instanz bereits eine Session erstellt wurde. Versuche `logout()` vor `createSession()` aufzurufen oder eine neue Instanz zu erstellen
  ///* `WrongCredentialsException` Wenn der Benutzername oder das Passwort falsch ist.
  Future createSession({String username = "", String password = ""}) async {
    //clearTimetableCache();

    _manager = TimetableManager(this);

    if (_sessionValid) {
      throw UserAlreadyLoggedInException(
          "Der Benutzer ist bereits eingeloggt. Veruche eine neues User Objekt zu erstellen oder die Funktion 'logout()' vorher aufzurufen!");
    }

    if (username == UserSession.demoAccountName) {
      _sessionValid = true;
      _debugSession = true;
      _un = UserSession.demoAccountName;
      _pwd = UserSession.demoAccountName;
      return;
    }

    if (username == "" || password == "") {
      throw MissingCredentialsException("Bitte gib einen Benutzenamen und ein Passwort an");
    }

    RPCResponse response =
        await _queryRPC("authenticate", {"user": username, "password": password, "client": _appName});

    if (response.isHttpError) {
      if (response.httpResponseCode == 501) {
        throw ApiConnectionError(
            "hepta.webuntis.com Wartungsarbeiten oder nicht verfügbar. Bitte versuche es später erneut.");
      } else {
        throw ApiConnectionError("Ein http Fehler ist aufegteten: " +
            response.errorMessage +
            "(" +
            response.httpResponseCode.toString() +
            ")");
      }
    } else if (response.isError) {
      if (response.rpcResponseCode == RPCResponse.rpcWrongCredentials) {
        throw WrongCredentialsException("Benutzename oder Passwort falsch");
      } else {
        throw ApiConnectionError("Ein unbekannter Fehler ist aufgetreten: " +
            response.errorMessage +
            "(" +
            response.rpcResponseCode.toString() +
            ")");
      }
    }

    _sessionId = response.payloadData['sessionId'];
    _personId = response.payloadData['personId'];
    _schoolClassId = response.payloadData['klasseId'];
    _type = PersonTypeUtils.parse(response.payloadData['personType']);

    _sessionValid = true;
    _un = username;
    _pwd = password;

    await regenerateSessionBearerToken(); //14375
    _cachedProfileData = await getProfileData(loadFromCache: false);

    await getTimegrid().then((value) {
      _loadedTimegrid = value;
      if (_manager != null && _loadedTimegrid != null) {
        _manager!.setTimegrid(_loadedTimegrid!);
      } else {
        log.w("Falling back to static timegrid.");
      }
    });

    //setTimetableBehavior(2162, PersonTypes.klasse);
  }

  String get sessionid => _sessionId;

  String get bearerToken => _bearerToken;

  bool get isDemoSession => _debugSession;

  ///Muss üblicherweise nicht aufgerufen werden.
  Future regenerateSessionBearerToken() async {
    //Bearer Token für aktuelle Session holen.
    http.Response r = await _queryURL("/WebUntis/api/token/new");
    if (r.statusCode == 200) {
      _bearerToken = r.body;
    } else {
      //print("Warning: Failed to fetch api token. Unable to call 'getNews()' and 'getProfileData()'");
    }
  }

  ///Der Benutzername.
  String getUsername() {
    return _un;
  }

  ///Name der Schule wie sie in webuntis registriert ist
  String getSchool() {
    return _school;
  }

  ///Die Rolle der eingeloggten Person. Es gibt "Schüler" und "Lehrer"
  PersonTypes get personType => _type;

  ///Loggt einen user aus und beendet die Session automatisch. Sie kann mit einem erneuten Login (createSession(...)) wieder aktiviert werden
  ///Wenn versucht wird nach dem ausloggen und vor einem wieder einloggen Daten zu holen wird der Fehler "Die Session ist ungültig" geworfen.*/
  Future<RPCResponse> logout() async {
    RPCResponse response = await _queryRPC("logout", {}, validateSession: false);
    _sessionValid = false;
    _sessionId = "";
    _un = "";
    _pwd = "";
    _personId = -1;
    _schoolClassId = -1;
    _type = PersonTypes.unknown;
    _bearerToken = "";
    clearManagerCache();
    return response;
  }

  ///Gibt true zurück, wenn in diesem Objekt ein Benutzer eingeloggt ist
  bool isLoggedIn() {
    return _sessionId.isNotEmpty && _sessionValid && _personId != -1;
  }

  ///Gibt true zurück, wenn der user eingeloggt ist und JsonRPC API Anfragen stellen darf
  bool isRPCAuthroized() {
    return _sessionId.isNotEmpty && _personId != -1;
  }

  ///Gibt true zurück, wenn der user eingeloggt ist und API Anfragen stellen darf
  bool isAPIAuthorized() {
    return _bearerToken.isNotEmpty;
  }

  ///* Benötigt einen erfolgreich generierten Bearer Token (Passiert automatisch)
  Future<News> getNewsData(DateTime date, {bool loadFromCache = true}) async {
    if (!loadFromCache || _cachedNewsData.getRssUrl() == "") {
      http.Response r = await _queryURL(
          "/WebUntis/api/public/news/newsWidgetData?date=" + Utils.convertToUntisDate(date),
          needsAuthorization: true);
      _cachedNewsData = News(jsonDecode(r.body));
    }

    return _cachedNewsData;
  }

  Future regenerateSession() async {
    if (!_sessionValid) {
      return;
    }

    await _validateSession();
  }

  Future<Timegrid?> getTimegrid() async {
    if (isAPIAuthorized()) {
      try {
        http.Response r = await _queryURL("/WebUntis/api/rest/view/v1/timegrid", needsAuthorization: true);
        log.i("Dynamic timegrid loaded from WebUntis");
        return Timegrid(jsonDecode(r.body));
      } catch (e) {
        log.e("Failed to load timegrid: " + e.toString() + "");
        return null;
      }
    }
    return null;
  }

  ///Gibt Profil Daten wie Name, Profilbild etc. in einem `ProfileData` Objekt zurück.
  ///* Benötigt einen erfolgreich generierten Bearer Token (Passiert automatisch)
  ///
  ///Da die Profil Daten sich innerhalb einer Instanz nicht (oder nur selten) ändern sollten wird nur beim ersten Aufruf dieser Funktion eine API anfrage gesendet.
  ///Erfolgreich geladene Profildaten werden gecached.
  ///Falls frische Serverdaten erzwungen werden sollten, [loadFromCache] auf false setzen.
  Future<ProfileData> getProfileData({bool loadFromCache = true}) async {
    if (!loadFromCache || _cachedProfileData.getSchoolId() == -1) {
      http.Response r = await _queryURL("/WebUntis/api/rest/view/v1/app/data", needsAuthorization: true);
      _cachedProfileData = ProfileData(jsonDecode(r.body));
    }

    return _cachedProfileData;
  }

  ///Die URL des Profilbildes von `getProfileData()` gecached.
  ///Wird üblicherweise beim Login abgefragt und kann hier direkt abgerufen werde
  ///Für mehr details, benutze `getProfileData()`
  String getCachedProfilePictureUrl() {
    return _cachedProfileData.getProfilePictureURL();
  }

  ///Nach und Vornamen von `getProfileData()` gecached.
  ///Wird üblicherweise beim Login abgefragt und kann hier direkt abgerufen werden.
  ///Für mehr details, benutze `getProfileData()`
  ///Um Namen getrennt zu bekommen `getProfileData().getNameSeparated()` aufrufen.
  String getCachedProfileFirstAndLastName() {
    return _cachedProfileData.getFirstAndLastName();
  }

  ///Den langen Schulnamen: "BBS I für gewerberbe" blah ...
  ///Wrapper für `getProfileData().getSchoolLongName()`
  ///
  ///Könnte eine `FailedToFetchUserdata` exception werfen.
  Future<String> getProfileSchoolName() async {
    ProfileData data = await getProfileData();
    return data.getSchoolLongName();
  }

  ///Die ID der Klasse in der der Schüler ist
  int get schoolClassId => _schoolClassId;

  // TODO(philipp): automate frame assignment
  Future<TimeTableRange> getTimeTable(DateTime from, DateTime to, TimetableFrame frame,
      {int personId = -1, PersonTypes personType = PersonTypes.unknown}) async {
    if (!_sessionValid) throw Exception("Die Session ist ungültig.");

    TimeTableRange loaded = TimeTableRange(
        from,
        to,
        frame,
        await _queryRPC("getTimetable", {
          "options": {
            "startDate": Utils.convertToUntisDate(from),
            "endDate": Utils.convertToUntisDate(to),
            "element": {
              "id": personId == -1 ? _personId : personId,
              "type": personType == PersonTypes.unknown ? _type.id : personType.id
            },
            "showLsText": true,
            "showPeText": true,
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

    return loaded;
  }

  /// Diese müssen in den Header gelegt werden
  String _buildAuthCookie() {
    if (!_sessionValid) return "";
    return "JSESSIONID=" + _sessionId + "; schoolname=" + _schoolBase64.replaceAll("=", "%3D");
  }

  Future _validateSession() async {
    _sessionValid = false;
    log.i("Re- validating session ...");
    await createSession(username: _un, password: _pwd);
  }

  Future<http.Response> _queryURL(String url, {bool needsAuthorization = false}) async {
    if (needsAuthorization && !isAPIAuthorized()) {
      //print("Failed to fetch bearer token. Retrying ...");
      await regenerateSessionBearerToken();
    }

    Map<String, String> header = {};
    if (needsAuthorization) {
      header = {
        'Content-type': 'application/json',
        'Cookie': _buildAuthCookie(),
        'Authorization': "Bearer " + _bearerToken
      };
    } else {
      header = {
        'Content-type': 'application/json',
        'Cookie': _buildAuthCookie(),
      };
    }

    return http.Client().get(Uri.parse(apiBaseUrl + url), headers: header);
  }

  Future<RPCResponse> _queryRPC(String method, Object params, {bool validateSession = true}) async {
    Object build = {"id": _appName, "method": method, "params": params, "jsonrpc": 2.0};

    RPCResponse orig = RPCResponse.handle(await http.Client().post(Uri.parse(rpcUrl),
        headers: {'Content-type': 'application/json', 'Cookie': _buildAuthCookie()}, body: jsonEncode(build)));

    if (validateSession && orig.rpcResponseCode == -8520 && _sessionValid) {
      log.v("Re- validating Session");
      await _validateSession();
      if (_sessionValid) {
        return RPCResponse.handle(await http.Client().post(Uri.parse(rpcUrl),
            headers: {'Content-type': 'application/json', 'Cookie': _buildAuthCookie()}, body: jsonEncode(build)));
      } else {
        throw Exception("Failed to revalidate session. Please log out and in again manually");
      }
    } else {
      return orig;
    }
  }

  void clearManagerCache() {
    if (!isDemoSession) {
      getTimetableManager().clearFrameCache();
    }
  }

  TimetableManager getTimetableManager() {
    return _manager!;
  }

  ///Diese Funktion dient nur noch als Wrapper
  ///Gibt einen Wochenstundenplan relativ zur derzeitigen Woche zurück. Von Montag bis Sonntag
  ///
  ///Um den Stundenplan von jemand anderen zu laden, können optional die Parameter personId und personType gesetzt werden
  ///
  ///* `getRelativeTimeTableWeek(-1);` gibt die vorherige Woche zur aktuellen zurück
  ///* `getRelativeTimeTableWeek(1);` gibt die nächste Woche zurück.
  ///* `getRelativeTimeTableWeek(0);` entspricht `getTimeTableForThisWeek()`
  Future<TimeTableRange> getRelativeTimeTableWeek(int relative,
      {int personId = -1, PersonTypes personType = PersonTypes.unknown}) async {
    TimetableFrame frame = getTimetableManager().getFrameRelativeToCurrent(relative);
    return await frame.getWeekData(personId: _timetablePersonId, personType: _timetablePersonType);
  }

  ///Gibt alle Klassen zurück, die der Lehrer unterrichtet in der gegebenen Range
  Future<List<SchoolClass>> getClassesAsTeacher({int checkRange = 2}) async {
    if (checkRange <= 0) {
      checkRange = 2;
    }

    var allClasses = await getSchoolClasses();
    var filtered = <SchoolClass>[];

    for (int i = -checkRange; i < checkRange + 1; i++) {
      TimeTableRange rng = await getTimetableManager().getFrameRelativeToCurrent(i).getWeekData();
      if (!rng.isNonSchoolblockWeek()) {
        for (int x = 0; x < rng.getDays().length; x++) {
          for (int y = 0; y < rng.getDays()[0].getHours().length; y++) {
            TimeTableHour hour = rng.getHourByIndex(xIndex: x, yIndex: y);

            if (hour.lessonCode != Codes.empty) {
              if (hour.teacher.identifier == _personId) {
                bool added = false;
                for (int j = 0; j < filtered.length; j++) {
                  if (filtered[j].name == hour.schoolClass.name) {
                    added = true;
                    break;
                  }
                }
                if (!added) {
                  for (SchoolClass s in allClasses) {
                    if (s.id == hour.schoolClass.identifier) {
                      filtered.add(s);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return filtered;
  }

  ///Gibt alle Klassen der Schule zurück
  Future<List<SchoolClass>> getSchoolClasses() async {
    if (personType != PersonTypes.teacher) {
      throw InsufficientPermissionsException("This user is not a teacher");
    }

    http.Response r = await _queryURL("/WebUntis/api/public/timetable/weekly/pageconfig?type=1");
    var schoolClasses = <SchoolClass>[];

    if (r.statusCode == 200) {
      dynamic json = jsonDecode(r.body);

      for (dynamic d in json["data"]["elements"]) {
        schoolClasses.add(SchoolClass(d));
      }
    } else {
      throw ApiConnectionError("Failed to fetch class info for school: Connection error");
    }
    return schoolClasses;
  }

  ///Gibt alle Klassen zurück der der Lehrer als Klassen hat
  Future<List<SchoolClass>> getOwnClassesAsClassteacher({String simulateTeacher = ""}) async {
    var schoolClasses = <SchoolClass>[];
    var all = await getSchoolClasses();
    String displayName =
        simulateTeacher != "" ? simulateTeacher : (await getProfileData(loadFromCache: true)).getFirstAndLastName();

    for (SchoolClass schoolClass in all) {
      if (schoolClass.classTeacherName == displayName || schoolClass.classTeacher2Name == displayName) {
        schoolClasses.add(schoolClass);
      }
    }
    return schoolClasses;
  }

  void resetTimetableBehaviour() {
    if (_un != demoAccountName) {
      _debugSession = false;
    }

    _timetablePersonId = _personId;
    _timetablePersonType = _type;
    getTimetableManager().clearFrameCache(hardReset: true);
  }

  ///Gibt an welcher Stundenplan geladen werden soll. Die Id ist egal. Das kann ein schüler, lehrer raum sein.
  ///Wichtig ist, dass der [type] entsprechend passt
  ///
  ///Um das Stundenplanladen wieder auf die angemeldete Person zurückzusetzen,
  ///benutze `resetTimetableLoading()`
  ///Wenn [debug] true ist, dann wird der Debug Stundenplan geladen
  void setTimetableBehaviour(int id, PersonTypes type, {bool debug = false}) {
    getTimetableManager().clearFrameCache(hardReset: true);

    if (debug) {
      _debugSession = true;
      return;
    }

    _timetablePersonType = type;
    _timetablePersonId = id;
  }
}
