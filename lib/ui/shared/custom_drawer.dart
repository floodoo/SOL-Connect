import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/login/login.screen.dart';
import 'package:sol_connect/ui/screens/settings/settings.screen.dart';
import 'package:sol_connect/ui/screens/teacher_classes/teacher_classes.screen.dart';
import 'package:sol_connect/ui/screens/time_table/time_table.screen.dart';

class CustomDrawer extends StatefulHookConsumerWidget {
  const CustomDrawer({Key? key}) : super(key: key);
  static final routeName = (CustomDrawer).toString();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  String username = "";
  String school = "";

  @override
  void initState() {
    getUserDataFromStorage();
    super.initState();
  }

  Future<void> getUserDataFromStorage() async {
    username = await ref.read(timeTableService).getUserName();
    school = await ref.read(timeTableService).getSchool();
    // setState to update username and school
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeService).theme;
    final session = ref.watch(timeTableService).session;

    // default circle avatar
    CircleAvatar profileAvatar = CircleAvatar(
      backgroundColor: theme.colors.background,
      child: Icon(Icons.person, color: theme.colors.circleAvatar),
    );

    // check authorization and if user has a profile picture
    if (session.isAPIAuthorized()) {
      final profilePictureUrl = session.getCachedProfilePictureUrl();

      if (profilePictureUrl.isNotEmpty) {
        profileAvatar = CircleAvatar(
            backgroundColor: theme.colors.background, backgroundImage: Image.network(profilePictureUrl).image);
      }
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              username,
              style: TextStyle(color: theme.colors.text),
            ),
            accountEmail: Text(
              school,
              style: TextStyle(color: theme.colors.text),
            ),
            currentAccountPicture: profileAvatar,
            decoration: BoxDecoration(
              color: theme.colors.primary,
            ),
          ),
          ListTile(
            title: Text("Mein Stundenplan", style: TextStyle(color: theme.colors.textBackground)),
            onTap: () {
              if (ref.read(timeTableService).session.personType == PersonTypes.teacher) {
                ref.read(timeTableService).deletePhase();
              }

              ref.read(timeTableService).resetAndGetTimeTable();

              Navigator.pushReplacementNamed(context, TimeTableScreen.routeName);
            },
          ),
          Visibility(
            visible: ref.read(timeTableService).session.personType == PersonTypes.teacher,
            child: ListTile(
              title: Text("Unterricht", style: TextStyle(color: theme.colors.textBackground)),
              onTap: () {
                ref.read(timeTableService).deletePhase();
                ref.read(timeTableService).resetAndGetTimeTable();
                Navigator.pushNamed(context, TeacherClassesScreen.routeName);
              },
            ),
          ),
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
    );
  }
}
