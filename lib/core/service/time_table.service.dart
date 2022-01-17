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

  //True wenn eine Phasierungsdatei erfolgreich geladen und verifiziert werden konnte
  bool phaseVerified = false;
  
  bool isLoggedIn = false;
  bool isLoading = false;
  bool isSchool = true;
  bool weekInBlock = false;
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
        isLoggedIn = true;
        await getTimeTable();
        try {
          await loadCheckedPhaseFileForNextBlock();
        } catch (e) {
          log.e(e);
        }
        UserSecureStorage.setPassword(password);
        log.i("Successfully logged in");
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
    if (timeTable != null) {
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
    password = "";
    session.logout();
    notifyListeners();
  }

  ///Es wird davon ausgegangen, dass die geladene Datei gültig ist
  loadUncheckedPhaseFileForNextBlock() async {
    await loadPhaseFromFile();
    await loadPhase();
  }

  ///Die Datei wird mit ausführlichen checks geladen und getestet.
  Future<String> loadCheckedPhaseFileForNextBlock([String? phaseFilePath]) async {
    phaseVerified = false;

    if (phaseFilePath != null) {
      prefs!.setString("phasePlan", phaseFilePath);
      validator = ExcelValidator("flo-dev.me", phaseFilePath);
    } else {
      phaseFilePath = prefs!.getString("phasePlan") ?? "empty";
      if (phaseFilePath != "empty") {
        validator = ExcelValidator("flo-dev.me", phaseFilePath);
      }
    }

    log.d("Verifying phaseplan for next/current block ...");

    await session.clearTimetableCache();

    timeTable = await session.getRelativeTimeTableWeek(0);
    //Block ausmappen

    DateTime blockStart = await timeTable!.getNextBlockStartDate(0);
    DateTime blockEnd = await timeTable!.getNextBlockEndDate(0);

    log.d("Limiting Phaseplan to block " +
      blockStart.toString() +
      " -> " +
      blockEnd.toString() +
      " until a new file is loaded.");

    UserSecureStorage.setPhaseLoadDateStart(blockStart);
    UserSecureStorage.setPhaseLoadDateEnd(blockEnd);

    var nextBlockweeks = await timeTable!.getNextBlockWeeks(0);
    //Überprüfe alle nächsten Block Wochen!
    validator!.limitPhasePlanToCurrentBlock(blockStart, blockEnd);
    
    for(TimeTableRange blockWeek in nextBlockweeks) {
      log.d("Verifying block week phase merge " + blockWeek.getStartDateString() + " -> " + blockWeek.getEndDateString());
      await validator!.mergeExcelWithTimetable(blockWeek);
    }
    phaseVerified = true;
    log.i("File verified!");
    //Success!
    
    getTimeTable(weekCounter: _weekCounter);

    session.clearTimetableCache();
    return "";
  }

  ///Ladet ein neuen ExcelValidator aus einer Datei
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

  ///Ladet die Phase zu einem Stundenplan
  Future<void> loadPhase() async {
    weekInBlock = true;

    if (validator != null) {
      try {
        phaseTimeTable = await validator!.mergeExcelWithTimetable(timeTable!);
      } on CurrentPhaseplanOutOfRange {
        phaseTimeTable = null;
        log.e("Week not part of current block");
        weekInBlock = false;
      } 
      notifyListeners();
    }
  }

  void deletePhase() {
    prefs!.remove("phasePlan");
    validator = null;
    phaseVerified = false;
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
