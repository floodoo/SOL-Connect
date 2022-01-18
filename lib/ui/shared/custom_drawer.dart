import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/api/usersession.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/login/login.screen.dart';
import 'package:untis_phasierung/ui/screens/settings/settings.screen.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';
import 'dart:math';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({Key? key}) : super(key: key);
  static final routeName = (CustomDrawer).toString();
  static Random r = Random();

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
      ImageProvider pp;
      if (r.nextInt(69) == 20) {
        pp = const Image(image: AssetImage('assets/images/trollface.png')).image;
      } else {
        profilePictureUrl = session.getCachedProfilePictureUrl();
        pp = Image.network(profilePictureUrl).image;
      }

      profilePicture = CircleAvatar(
        backgroundColor: theme.colors.background,
        backgroundImage: pp,
      );
    } else {
      profilePicture = CircleAvatar(
        backgroundColor: theme.colors.background,
        child: Icon(
          Icons.person,
          color: theme.colors.circleAvatar,
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: theme.colors.background,
      ),
      child: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(username, style: TextStyle(color: theme.colors.text)),
              accountEmail: Text("bbs1-mainz", style: TextStyle(color: theme.colors.text)),
              currentAccountPicture: profilePicture,
              decoration: BoxDecoration(
                color: theme.colors.primary,
              ),
            ),
            ListTile(
              title: Text("Stundenplan", style: TextStyle(color: theme.colors.textBackground)),
              onTap: () => Navigator.popAndPushNamed(context, TimeTableScreen.routeName),
            ),
            // ListTile(
            //   title: Text("Info-Center", style: TextStyle(color: theme.colors.textBackground)),
            //   onTap: () => Navigator.of(context).pop(),
            // ),
            // ListTile(
            //   title: Text("Notifications", style: TextStyle(color: theme.colors.textBackground)),
            //   onTap: () => Navigator.of(context).pop(),
            // ),
            // ListTile(
            //   title: Text("Messages: {0}", style: TextStyle(color: theme.colors.textBackground)),
            //   onTap: () => Navigator.of(context).pop(),
            // ),
            ListTile(
              title: Text("🚧 Weitere Features kommen noch 🚧", style: TextStyle(color: theme.colors.textBackground)),
              onTap: null,
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
      ),
    );
  }
}
