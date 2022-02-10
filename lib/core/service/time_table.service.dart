import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sol_connect/core/api/timetable.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/excel/models/mergedtimetable.dart';
import 'package:sol_connect/core/excel/models/version.dart';
import 'package:sol_connect/core/excel/solc_api_manager.dart';
import 'package:sol_connect/core/excel/validator.dart';
import 'package:sol_connect/core/exceptions.dart';
import 'package:sol_connect/util/logger.util.dart';
import 'package:sol_connect/util/user_secure_stotage.dart';

class TimeTableService with ChangeNotifier {
  final Logger log = getLogger();

  late UserSession session;

  TimeTableRange? timeTable;
  MergedTimeTable? phaseTimeTable;
  ExcelValidator? validator;
  SOLCApiManager? apiManager;

  SharedPreferences? prefs;

  bool isLoggedIn = false;
  bool isLoading = false;
  bool isSchool = true;
  bool isPhaseVerified = false;
  bool isWeekInBlock = false;
  int weekCounter = 0;

  String username = "";
  String password = "";
  String schoolName = "";

  dynamic loginException;

  Future<void> saveSchoolName(String schoolName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("schoolName", schoolName);
    this.schoolName = schoolName;
    notifyListeners();
  }

  void getSchoolName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    schoolName = prefs.getString("schoolName") ?? "bbs1-mainz";
    notifyListeners();
  }

  Future<String> getServerAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("serverAddress") ?? "flo-dev.me";
  }

  Future<void> login(String username, String password) async {
    apiManager = SOLCApiManager(await getServerAddress(), 6969);

    //apiManager = SOLCApiManager("127.0.0.1", 6969);

    apiManager!.getVersion().then((value) {
      //Dieser Build benötigt Server version > 2.1.5
      if (Version.isOlder(value, SOLCApiManager.buildRequired)) {
        log.e(
            "This build requires SOLC-API Server version > v${SOLCApiManager.buildRequired} (${apiManager!.inetAddress} running on: v$value) Unexpected errors may happen!");
      }
    }).catchError((error, stackTrace) {
      log.w("Failed to verify SOLC-API Server version. Unexpected errors may happen!");
    });

    UserSecureStorage.setUsername(username);
    prefs = await SharedPreferences.getInstance();
    session = UserSession(school: schoolName, appID: "untis-phasierung");

    prefs!.remove("phasePlan");

    try {
      await session.createSession(username: username, password: password);

      isLoggedIn = true;
      await getTimeTable();

      try {
        await loadCheckedVirtualPhaseFileForNextBlock();
      } catch (e, stacktrace) {
        log.e(stacktrace);
        deletePhase();
      }

      UserSecureStorage.setPassword(password);
      log.i("Successfully logged in");
      notifyListeners();
    } catch (error, stacktrace) {
      log.e(stacktrace);
      log.e("Error logging in: $error");

      UserSecureStorage.clearAll();

      isLoading = false;
      this.username = "";
      this.password = "";
      loginException = error;
      notifyListeners();
    }
  }

  void logout() {
    UserSecureStorage.clearPassword();
    isLoggedIn = false;
    isLoading = false;
    timeTable = null;
    phaseTimeTable = null;
    loginException = null;
    password = "";
    session.logout();
    deletePhase();
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

  ///Dafür zuständig die Phasen im Validator für den aktuellen Block zu verifizieren
  Future<void> _verifyBlockPhases() async {
    log.d("Verifying phaseplan for next/current block ...");

    session.clearManagerCache();

    timeTable = await session.getRelativeTimeTableWeek(0);

    if (validator == null) {
      deletePhase();
      log.d("No phase file specified. Skipping phase loading ...");
    }

    await validator!.mergeExcelWithWholeBlock(session);

    isPhaseVerified = true;
    log.i("File verified!");

    getTimeTable(weekCounter: 0);
  }

  ///Phasierung einer "Virtuellen" Datei überprüfen und in den preferences speichern
  ///
  ///[persistent] gibt an, ob die bytes gespeichert werden sollten
  Future<void> loadCheckedVirtualPhaseFileForNextBlock({List<int>? bytes, bool persistent = true}) async {
    if (bytes != null) {
      if (persistent) {
        prefs!.setStringList("phase-data", bytes.map((e) => e.toString()).toList());
      }
      validator = ExcelValidator(apiManager!, bytes);
    } else {
      List<String>? list = prefs!.getStringList("phase-data");
      if (list != null) {
        validator = ExcelValidator(apiManager!, list.map((e) => int.parse(e)).toList());
      }
    }

    if (validator == null) {
      log.d("No phase file specified. Skipping phase loading ...");
      return;
    }

    await _verifyBlockPhases();
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

    prefs!.remove("phase-data");
    log.i("Deleted Phase block limitation");

    notifyListeners();
  }

  void resetWeekCounter() {
    weekCounter = 0;
    notifyListeners();
  }
}
