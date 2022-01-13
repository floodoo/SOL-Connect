import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/core/api/usersession.dart';
import 'package:untis_phasierung/core/excel/models/mergedtimetable.dart';
import 'package:untis_phasierung/core/excel/validator.dart';
import 'package:untis_phasierung/core/exceptions.dart';
import 'package:untis_phasierung/util/logger.util.dart';
import 'package:untis_phasierung/util/user_secure_stotage.dart';

class TimeTableService with ChangeNotifier {
  final Logger log = getLogger();
  SharedPreferences? prefs;

  late UserSession session;
  TimeTableRange? timeTable;
  MergedTimeTable? phaseTimeTable;
  ExcelValidator? validator;

  bool isLoggedIn = false;
  bool isLoading = false;
  bool isSchool = true;

  int _weekCounter = 0;

  String username = "";
  String password = "";

  dynamic loginError;

  Future<void> login(String username, String password) async {
    UserSecureStorage.setUsername(username);
    prefs = await SharedPreferences.getInstance();

    session = UserSession(school: "bbs1-mainz", appID: "untis-phasierung");
    session.createSession(username: username, password: password).then(
      (value) async {
        log.i("Successfully logged in");
        isLoggedIn = true;
        await getTimeTable();
        UserSecureStorage.setPassword(password);
        notifyListeners();
      },
    ).catchError(
      (error) {
        log.e("Error logging in: $error");
        log.d("Clearing user data");
        UserSecureStorage.clear();
        loginError = true;
        isLoading = false;
        this.username = "";
        this.password = "";
        loginError = error;
        notifyListeners();
      },
    );
  }

  getTimeTable({int weekCounter = 0}) async {
    log.d("Getting timetable");
    
    timeTable = await session.getRelativeTimeTableWeek(weekCounter);
    if(timeTable != null) {
      isSchool = !timeTable!.isNonSchoolblockWeek();
    } else {
      isSchool = false;
    }

    loadPhase().onError((error, stackTrace) => log.e(error));

    notifyListeners();
  }

  void toggleLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> getTimeTableNextWeek() async {
    _weekCounter++;
    await getTimeTable(weekCounter: _weekCounter);
    log.d(_weekCounter.toString());
  }

  Future<void> getTimeTablePreviousWeek() async {
    _weekCounter--;
    await getTimeTable(weekCounter: _weekCounter);
    log.d(_weekCounter.toString());
  }

  void resetTimeTable() {
    timeTable = null;
    notifyListeners();
  }

  Future<void> getUserData() async {
    username = await UserSecureStorage.getUsername() ?? "";
    password = await UserSecureStorage.getPassword() ?? "";
    notifyListeners();
  }

  void setUsername(String value) {
    username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    isLoading = false;
    timeTable = null;
    phaseTimeTable = null;
    loginError = null;
    session.logout();
    notifyListeners();
  }

  Future<void> loadPhaseFromFile([String? phaseFilePath]) async {
    if (phaseFilePath != null) {
      prefs!.setString("phasePlan", phaseFilePath);
      validator = ExcelValidator("flo-dev.me", phaseFilePath);
    } else {
      phaseFilePath = prefs!.getString("phasePlan") ?? "empty";
      if (phaseFilePath != "empty") {
        validator = ExcelValidator("flo-dev.me", phaseFilePath);
      }
    }
  }

  Future<void> loadPhase() async {

    if (validator != null) {
      try {
        DateTime? loadStart = await UserSecureStorage.getPhaseLoadBlockStart();
        DateTime? loadEnd = await UserSecureStorage.getPhaseLoadBlockEnd();
        
        if(loadStart != null && loadEnd != null) {
          validator!.limitPhasePlanToCurrentBlock(loadStart, loadEnd);
          log.d("Limiting Phaseplan to block " + loadStart.toString() + " -> " + loadEnd.toString() + " until a new file is loaded.");
          phaseTimeTable = await validator!.mergeExcelWithTimetable(timeTable!);

        } else {
          phaseTimeTable = await validator!.mergeExcelWithTimetable(timeTable!);
          DateTime start = validator!.getBlockStart()!;
          DateTime end = validator!.getBlockEnd()!;
          log.d("Setting Phaseplan limitation to current block: " + start.toString() + " -> " + end.toString());
          UserSecureStorage.setPhaseLoadDateStart(start);
          UserSecureStorage.setPhaseLoadDateEnd(end);
        }

      } on CurrentPhaseplanOutOfRange {
        phaseTimeTable = null;
        log.e("Week not part of current block");
      }
    }
    notifyListeners();
  }

  void deletePhase() {
    prefs!.remove("phasePlan");
    validator = null;
    phaseTimeTable = null;
    
    UserSecureStorage.clearPhaseDates();
    log.i("Deleted Phase block limitation");

    notifyListeners();
  }

  void toggleSchool() {
    isSchool = isSchool ? false : true;
    notifyListeners();
  }
}
