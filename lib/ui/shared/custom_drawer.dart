import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'dart:math';

import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/login/login.screen.dart';
import 'package:sol_connect/ui/screens/settings/settings.screen.dart';
import 'package:sol_connect/ui/screens/teacher_classes/teacher_classes.screen.dart';
import 'package:sol_connect/ui/screens/time_table/time_table.screen.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({Key? key}) : super(key: key);
  static final routeName = (CustomDrawer).toString();
  static Random random = Random();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    UserSession session = ref.watch(timeTableService).session;
    String username = ref.watch(timeTableService).username;

    String profilePictureUrl = "";

    CircleAvatar profilePicture = CircleAvatar(child: CircularProgressIndicator(color: theme.colors.text));

    if (session.isAPIAuthorized()) {
      ImageProvider? imageProvider;
      if (random.nextInt(100) == 20) {
        imageProvider = const Image(image: AssetImage('assets/images/trollface.png')).image;
      } else {
        profilePictureUrl = session.getCachedProfilePictureUrl();
        if (profilePictureUrl.isNotEmpty) {
          imageProvider = Image.network(profilePictureUrl).image;
        }
      }
      if (imageProvider != null) {
        profilePicture = CircleAvatar(backgroundColor: theme.colors.background, backgroundImage: imageProvider);
      } else {
        profilePicture = CircleAvatar(
          backgroundColor: theme.colors.background,
          child: Icon(Icons.person, color: theme.colors.circleAvatar),
        );
      }
    } else {
      profilePicture = CircleAvatar(
        backgroundColor: theme.colors.background,
        child: Icon(Icons.person, color: theme.colors.circleAvatar),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: theme.colors.background),
      child: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(username + " (Rolle " + session.personType.readable + ")",
                  style: TextStyle(color: theme.colors.text)),
              accountEmail: Text(ref.watch(timeTableService).schoolName, style: TextStyle(color: theme.colors.text)),
              currentAccountPicture: profilePicture,
              decoration: BoxDecoration(
                color: theme.colors.primary,
              ),
            ),
            ListTile(
                title: Text("Mein Stundenplan", style: TextStyle(color: theme.colors.textBackground)),
                onTap: () {
                  ref.read(timeTableService).session.resetTimetableLoading();
                  ref.read(timeTableService).resetTimeTable();
                  ref.read(timeTableService).getTimeTable(weekCounter: 0);

                  Navigator.popAndPushNamed(context, TimeTableScreen.routeName);
                }),
            Visibility(
              visible: ref.read(timeTableService).session.personType == PersonTypes.teacher,
              child: ListTile(
                title: Text("Ihre Klassen", style: TextStyle(color: theme.colors.textBackground)),
                onTap: () => Navigator.pushNamed(context, TeacherClassesScreen.routeName),
              ),
            ),
            // For white space
            Expanded(child: Container()),
            ListTile(
              title: Text("Einstellungen", style: TextStyle(color: theme.colors.textBackground)),
              onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
            ),
            ListTile(
              title: Text(
                "Logout",
                style: TextStyle(color: theme.colors.error),
              ),
              onTap: () {
                ref.read(timeTableService).logout();
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
