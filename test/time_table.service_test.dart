import 'package:flutter_test/flutter_test.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/exceptions.dart';

void main() {
  // ! Don't push your password
  const username = "";
  const password = "";

  group("login", () {
    test("missing credentails", () async {
      try {
        final session = UserSession(school: "bbs1-mainz", appID: "untis-phasierung");
        await session.createSession(username: "", password: "");
      } catch (e) {
        expect(e.runtimeType, MissingCredentialsException);
      }
    });

    test("wrong credentails", () async {
      try {
        final session = UserSession(school: "bbs1-mainz", appID: "untis-phasierung");
        await session.createSession(username: "abcdefg", password: "abcdefg");
      } catch (e) {
        expect(e.runtimeType, WrongCredentialsException);
      }
    });

    test("login", () async {
      final session = UserSession(school: "bbs1-mainz", appID: "untis-phasierung");
      await session.createSession(username: username, password: password);
      expect(session.isLoggedIn(), true);
    });
  });

  test("logout", () async {
    final session = UserSession(school: "bbs1-mainz", appID: "untis-phasierung");
    await session.createSession(username: username, password: password);
    final response = await session.logout();
    expect(response.isError, false);
    expect(session.isLoggedIn(), false);
    expect(session.sessionid, isEmpty);
  });

  group("timetable", () {
    late UserSession session;

    setUp(() async {
      session = UserSession(school: "bbs1-mainz", appID: "untis-phasierung");
      await session.createSession(username: username, password: password);
    });

    test("timetable exist", () async {
      final timetable = await session.getRelativeTimeTableWeek(0);
      expect(timetable.response.isError, false);
    });

    test("timetable day", () async {
      final timetable = await session.getRelativeTimeTableWeek(0);
      final timetableDayList = timetable.getDays();
      expect(timetableDayList.length, 7);
    });
  });

  group("profile", () {
    late UserSession session;

    setUp(() async {
      session = UserSession(school: "bbs1-mainz", appID: "untis-phasierung");
      await session.createSession(username: username, password: password);
    });

    test("name", () async {
      final profileData = await session.getProfileData();
      expect(profileData.getSchoolLongName(), isNotNull);
      expect(profileData.getSchoolLongName(), isNotEmpty);
      expect(profileData.getFirstAndLastName(), isNotNull);
      expect(profileData.getFirstAndLastName(), isNotEmpty);
    });

    test("picture", () async {
      final profileData = await session.getProfileData();
      expect(profileData.getProfilePictureURL(), isNotNull);
      expect(profileData.getProfilePictureURL(), isNotEmpty);
    });
  });
}
