import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/api/usersession.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/login/login.screen.dart';
import 'package:untis_phasierung/ui/screens/settings/settings.screen.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({Key? key}) : super(key: key);
  static final routeName = (CustomDrawer).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    String username = ref.watch(timeTableService).username;
    String profilePictureUrl = "";
    UserSession session = ref.watch(timeTableService).session;

    CircleAvatar profilePicture = CircleAvatar(
      child: CircularProgressIndicator(color: theme.colors.text),
    );

    if (session.isAPIAuthorized()) {
      profilePictureUrl = session.getCachedProfilePictureUrl();
      profilePicture = CircleAvatar(
          backgroundColor: theme.colors.background, backgroundImage: Image.network(profilePictureUrl).image);
    } else {
      profilePicture = CircleAvatar(
        backgroundColor: theme.colors.background,
        child: Icon(
          Icons.person,
          color: theme.colors.circleAvatar,
        ),
      );
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username),
            accountEmail: const Text("bbs1-mainz"),
            currentAccountPicture: profilePicture,
            decoration: BoxDecoration(
              color: theme.colors.primary,
            ),
          ),
          ListTile(
            title: const Text("Timetable"),
            onTap: () => Navigator.popAndPushNamed(context, TimeTableScreen.routeName),
          ),
          ListTile(
            title: const Text("Info-Center"),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: const Text("Notifications"),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: const Text("Messages: {0}"),
            onTap: () => Navigator.of(context).pop(),
          ),
          Expanded(child: Container()),
          ListTile(
            title: const Text("Settings"),
            onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
          ListTile(
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
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
