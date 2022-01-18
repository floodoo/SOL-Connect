/*Author Philipp Gersch */

import 'package:http/http.dart' as http;
import 'package:untis_phasierung/core/api/models/news.dart';
import 'package:untis_phasierung/core/api/models/profiledata.dart';
import 'package:untis_phasierung/core/api/models/utils.dart';
import 'package:untis_phasierung/core/api/rpcresponse.dart' as rh;
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/core/exceptions.dart';
import 'dart:convert';

class UserSession {
  String _appName = "adw8638ordfgq37qp98";
  String _sessionId = "";
  int _personId = -1;
  int _klasseId = -1;
  int _type = 0;

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

  //Gecachte timetables
  final _cachedTimetables = <TimeTableRange>[];
  //Wie viele timetables gecache werden dürfen bis alte recycled werden
  final int maxTimetableCacheSize = 10;
  //Ob caching überhaubt benutzt werden soll. Wird im Konstruktor festgelegt
  final bool useCaching;

  UserSession({String school = "", String appID = "", this.useCaching = true}) {
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
  Future<rh.RPCResponse> createSession({String username = "", String password = ""}) async {
    clearTimetableCache();

    if (_sessionValid) {
      throw UserAlreadyLoggedInException(
          "Der Benutzer ist bereits eingeloggt. Veruche eine neues User Objekt zu erstellen oder die Funktion 'logout()' vorher aufzurufen!");
    }

    if (username == "" || password == "") {
      throw MissingCredentialsException("Bitte gib einen Benutzenamen und ein Passwort an");
    }

    rh.RPCResponse response =
        await _queryRPC("authenticate", {"user": username, "password": password, "client": _appName});

    if (response.isHttpError()) {
      throw ApiConnectionError("Ein http Fehler ist aufegteten: " +
          response.getErrorMessage().toString() +
          "(" +
          response.getErrorCode().toString() +
          ")");
    } else if (response.isError()) {
      if (response.getErrorCode() == -8504) {
        throw WrongCredentialsException("Benutzename oder Passwort falsch");
      } else {
        throw ApiConnectionError("Ein Fehler ist aufgetreten: " +
            response.getErrorMessage().toString() +
            "(" +
            response.getErrorCode().toString() +
            ")");
      }
    }

    _sessionId = response.getPayloadData()['sessionId'];
    _personId = response.getPayloadData()['personId'];
    _klasseId = response.getPayloadData()['klasseId'];
    _type = response.getPayloadData()['personType'];

    _sessionValid = true;
    _un = username;
    _pwd = password;

    await regenerateSessionBearerToken();
    _cachedProfileData = await getProfileData(loadFromCache: false);

    return response;
  }

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
  String getPersonType() {
    if (_type == 2) {
      return "Lehrer";
    } else if (_type == 5) {
      return "Schüler";
    }
    return _type.toString();
  }

  ///Loggt einen user aus und beendet die Session automatisch. Sie kann mit einem erneuten Login (createSession(...)) wieder aktiviert werden
  ///Wenn versucht wird nach dem ausloggen und vor einem wieder einloggen Daten zu holen wird der Fehler "Die Session ist ungültig" geworfen.*/
  Future<rh.RPCResponse> logout() async {
    rh.RPCResponse response = await _queryRPC("logout", {}, validateSession: false);
    _sessionValid = false;
    _sessionId = "";
    _un = "";
    _pwd = "";
    _personId = -1;
    _klasseId = -1;
    _type = -1;
    _bearerToken = "";
    clearTimetableCache();
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
          "/WebUntis/api/public/news/newsWidgetData?date=" + Utils().convertToUntisDate(date),
          needsAuthorization: true);
      _cachedNewsData = News(jsonDecode(r.body));
    }

    return _cachedNewsData;
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
  int getKlasseId() {
    return _klasseId;
  }

  ///Gibt einen Wochenstundenplan relativ zur derzeitigen Woche zurück. Von Montag bis Sonntag
  ///
  ///* Das heißt `getRelativeTimeTableWeek(-1);` gibt die vorherige Woche zur aktuellen zurück
  ///* `getRelativeTimeTableWeek(1);` gibt die nächste Woche zurück.
  ///* `getRelativeTimeTableWeek(0);` entspricht `getTimeTableForThisWeek()`
  Future<TimeTableRange> getRelativeTimeTableWeek(int relative) async {
    /*DateTime from = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    if (relative < 0) {
      //Ziehe die duration ab und gehe in die Vergangenheit
      from = from.subtract(Duration(days: DateTime.daysPerWeek * relative.abs()));
    } else if (relative > 0) {
      //Addiere die Duration und gehe in die Zukunft.
      from = from.add(Duration(days: DateTime.daysPerWeek * relative));
    }*/
    DateTime from = getRelativeWeekStartDate(relative);
    DateTime lastDayOfWeek = from.add(Duration(days: DateTime.daysPerWeek - from.weekday + 1));
    TimeTableRange rng = await getTimeTable(from, lastDayOfWeek);
    rng.relativeToCurrent = relative;
    return rng;
  }

  ///Gibt nur das Datum einers Wochenstartes relativ zum aktuellen Datum zurück ohne ein extra Timetable Objekt abzufragen und zu erzeugen
  DateTime getRelativeWeekStartDate(int relative) {
    DateTime from = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    if (relative < 0) {
      //Ziehe die duration ab und gehe in die Vergangenheit
      from = from.subtract(Duration(days: DateTime.daysPerWeek * relative.abs()));
    } else if (relative > 0) {
      //Addiere die Duration und gehe in die Zukunft.
      from = from.add(Duration(days: DateTime.daysPerWeek * relative));
    }
    return from;
  }

  Future<TimeTableRange> getTimeTableForThisWeek() async {
    return getRelativeTimeTableWeek(0);
  }

  Future<TimeTableRange> getTimeTableForToday() async {
    if (!_sessionValid) throw Exception("Die Session ist ungültig.");

    return getTimeTable(DateTime.now(), DateTime.now());
  }

  ///Gibt null zurück wenn timetable nicht in cache vorhanden ist
  TimeTableRange? _getCachedTimetable(DateTime from, DateTime to) {
    for (TimeTableRange range in _cachedTimetables) {
      if (Utils().dateMatch(range.getStartDate(), from) && Utils().dateMatch(range.getEndDate(), to)) {
        return range;
      }
    }
  }

  void _addTimetableToCache(TimeTableRange range) {
    if (_getCachedTimetable(range.getStartDate(), range.getEndDate()) != null) {
      return;
    }

    if (_cachedTimetables.length < maxTimetableCacheSize) {
      _cachedTimetables.add(range);
    } else {
      //Lösche das erste element (Das sollte am längsten nicht mehr benutzt worden sein)
      _cachedTimetables.removeAt(0);
      _cachedTimetables.add(range);
    }
  }

  ///Löscht den Timetable cache. Falls useCaching true ist
  void clearTimetableCache() {
    _cachedTimetables.clear();
  }

  Future<TimeTableRange> getTimeTable(DateTime from, DateTime to) async {
    if (!_sessionValid) throw Exception("Die Session ist ungültig.");

    if (useCaching) {
      TimeTableRange? cached = _getCachedTimetable(from, to);
      if (cached != null) {
        return cached;
      }
    }

    TimeTableRange loaded = TimeTableRange(
        from,
        to,
        this,
        await _queryRPC("getTimetable", {
          "options": {
            "startDate": Utils().convertToUntisDate(from),
            "endDate": Utils().convertToUntisDate(to),
            "element": {"id": _personId, "type": _type},
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

    if (useCaching) {
      _addTimetableToCache(loaded);
    }

    return loaded;
  }

  /// Diese müssen in den Header gelegt werden
  String _buildAuthCookie() {
    if (!_sessionValid) return "";

    return "JSESSIONID=" + _sessionId + "; schoolname=" + _schoolBase64.replaceAll("=", "%3D");
  }

  Future<rh.RPCResponse> _validateSession() async {
    _sessionValid = false;
    return await createSession(username: _un, password: _pwd);
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

  Future<rh.RPCResponse> _queryRPC(String method, Object params, {bool validateSession = true}) async {
    Object build = {"id": _appName, "method": method, "params": params, "jsonrpc": 2.0};

    rh.RPCResponse orig = rh.RPCResponse.handle(await http.Client().post(Uri.parse(rpcUrl),
        headers: {'Content-type': 'application/json', 'Cookie': _buildAuthCookie()}, body: jsonEncode(build)));

    if (validateSession && orig.getErrorCode() == -8520 && _sessionValid) {
      rh.RPCResponse r = await _validateSession();
      if (!r.isError()) {
        return rh.RPCResponse.handle(await http.Client().post(Uri.parse(rpcUrl),
            headers: {'Content-type': 'application/json', 'Cookie': _buildAuthCookie()}, body: jsonEncode(build)));
      } else {
        return r;
      }
    } else {
      return orig;
    }
  }
}
