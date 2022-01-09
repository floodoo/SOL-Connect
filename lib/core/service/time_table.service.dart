import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
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
  ExcelValidator validator =
      ExcelValidator("flo-dev.me", "/Users/flo/development/privat/untis_phasierung/assets/excel/model1.xlsx");

  bool isLoggedIn = false;
  bool isLoading = false;
  bool isSchoolBlock = true;

  int _weekCounter = 0;

  String username = "";
  String password = "";

  dynamic loginError;

  void login(String username, String password) {
    UserSecureStorage.setUsername(username);

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
        if (error is ExcelMergeNonSchoolBlockException) {
          isSchoolBlock = false;
          notifyListeners();
        }
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
    try {
      phaseTimeTable = await validator.mergeExcelWithTimetable(timeTable!);
      isSchoolBlock = true;
      notifyListeners();
    } catch (e) {
      isSchoolBlock = true;
      notifyListeners();
      if (e is ExcelMergeNonSchoolBlockException) {
        isSchoolBlock = false;
        notifyListeners();
      } else {
        log.e(e);
      }
    }
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

  void logout() {
    isLoggedIn = false;
    isLoading = false;
    timeTable = null;
    phaseTimeTable = null;
    loginError = null;
    session.logout();
    notifyListeners();
  }
}
