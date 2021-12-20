import 'package:flutter/material.dart';
import 'package:untis_phasierung/ui/screens/login/login.screen.dart';
import 'package:untis_phasierung/ui/screens/timetable/timetable.screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);
  static final routeName = (CustomDrawer).toString();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("{User name}"),
            accountEmail: Text("{Schhol name}"),
            currentAccountPicture: CircleAvatar(
              foregroundImage: AssetImage("assets/images/example_profile_picture.jpeg"),
            ),
          ),
          ListTile(
            title: const Text("Timetable"),
            onTap: () => Navigator.popAndPushNamed(context, TimetableScreen.routeName),
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
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => Navigator.of(context).pushReplacementNamed(LoginScreen.routeName),
          ),
        ],
      ),
    );
  }
}
