import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/core/api/timetable_frame.dart';
import 'package:untis_phasierung/core/api/usersession.dart';
import 'package:untis_phasierung/core/excel/models/mergedtimetable.dart';
import 'package:untis_phasierung/core/excel/validator.dart';
import 'package:untis_phasierung/core/exceptions.dart';
import 'package:untis_phasierung/util/logger.util.dart';
import 'package:untis_phasierung/util/user_secure_stotage.dart';

class TimeTableService with ChangeNotifier {
  final Logger log = getLogger();

  late UserSession session;

  TimeTableRange? timeTable;
  MergedTimeTable? phaseTimeTable;
  ExcelValidator? validator;
  SharedPreferences? prefs;

  bool isLoggedIn = false;
  bool isLoading = false;
  bool isSchool = true;
  bool isPhaseVerified = false;
  bool isWeekInBlock = false;
  int weekCounter = 0;

  String username = "";
  String password = "";

  dynamic loginError;

  Future<void> login(String username, String password) async {

    UserSecureStorage.setUsername(username);
    prefs = await SharedPreferences.getInstance();

    session = UserSession(school: "bbs1-mainz", appID: "untis-phasierung");
    
    try { 
      
      await session.createSession(username: username, password: password);
      
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

    } catch(error) {
      log.e("Error logging in: $error");
      log.d("Clearing user data");

      UserSecureStorage.clearAll();

      loginError = true;
      isLoading = false;

      this.username = "";
      this.password = "";

      loginError = error;

      notifyListeners();
    } 


    /*await session.createSession(username: username, password: password).then(
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

        UserSecureStorage.clearAll();

        loginError = true;
        isLoading = false;

        this.username = "";
        this.password = "";

        loginError = error;

        notifyListeners();
      },
    );*/
  }

  void logout() {
    UserSecureStorage.clearPassword();
    isLoggedIn = false;
    isLoading = false;
    timeTable = null;
    phaseTimeTable = null;
    loginError = null;
    password = "";
    session.logout();
    notifyListeners();
    log.i("Logged out.");
  }

  Future<void> getTimeTable({int weekCounter = 0}) async {
    log.d("Getting timetable");

    timeTable = await session.getRelativeTimeTableWeek(weekCounter);
    if (timeTable != null) {
      isSchool = !timeTable!.isNonSchoolblockWeek();
    } else {
      isSchool = false;
    }

    await loadPhaseForCurrentTimetable().onError((error, stackTrace) => log.e(error));

    notifyListeners();
  }

  void toggleIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> getTimeTableNextWeek() async {
    weekCounter++;
    await getTimeTable(weekCounter: weekCounter);
    log.d(weekCounter.toString());
  }

  Future<void> getTimeTablePreviousWeek() async {
    weekCounter--;
    await getTimeTable(weekCounter: weekCounter);
    log.d(weekCounter.toString());
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

  Future<String> loadCheckedPhaseFileForNextBlock([String? phaseFilePath]) async {
    isPhaseVerified = false;
    
    log.d("Loading phaseplan ...");

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
    
    session.clearManagerCache();

    timeTable = await session.getRelativeTimeTableWeek(0);

    //log.d("Limiting Phaseplan to block " +
    //    blockStart.toString() +
    //    " -> " +
    //    blockEnd.toString() +
    //    " until a new file is loaded.");

    var nextBlockweeks = await timeTable!.getBoundFrame().getManager().getNextBlockWeeks();

    for (TimetableFrame blockWeek in nextBlockweeks) {
      log.d(
          "Verifying block week phase merge " + blockWeek.getFrameStart().toString() 
          + " -> " + blockWeek.getFrameEnd().toString());
      
      await blockWeek.getCurrentBlockWeek();
      await validator!.mergeExcelWithTimetable(await blockWeek.getWeekData());
    }

    isPhaseVerified = true;
    log.i("File verified!");

    getTimeTable(weekCounter: 0);

    return "";
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

  Future<void> loadPhaseForCurrentTimetable() async {
    isWeekInBlock = true;

    if (validator != null) {
      try {
        phaseTimeTable = await validator!.mergeExcelWithTimetable(timeTable!);
      } on CurrentPhaseplanOutOfRange {
        phaseTimeTable = null;
        log.e("Week not part of current block");
        isWeekInBlock = false;
      }
      notifyListeners();
    }
  }

  void deletePhase() {
    validator = null;
    isPhaseVerified = false;
    phaseTimeTable = null;

    prefs!.remove("phasePlan");

    log.i("Deleted Phase block limitation");

    notifyListeners();
  }

  void resetWeekCounter() {
    weekCounter = 0;
    notifyListeners();
  }
}
