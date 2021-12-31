import 'package:flutter/material.dart';
import 'package:untis_phasierung/ui/screens/login/login.screen.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';
import 'package:untis_phasierung/util/user_secure_stotage.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);
  static final routeName = (CustomDrawer).toString();

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String username = "";
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  loadUserData() async {
    final storedUsername = await UserSecureStorage.getUsername();

    setState(() {
      username = storedUsername ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username),
            accountEmail: const Text("bbs1-mainz"),
            currentAccountPicture: CircleAvatar(
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
              backgroundColor: Colors.grey[850],
            ),
            decoration: const BoxDecoration(
              color: Colors.black87,
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
