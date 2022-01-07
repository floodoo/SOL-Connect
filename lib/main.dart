import 'package:flutter/material.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';
import 'package:logger/logger.dart';
import 'package:untis_phasierung/ui/screens/login/login.screen.dart';

void main() {
  Logger.level = Level.debug;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Untis phasierung",
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        CustomDrawer.routeName: (context) => const CustomDrawer(),
        TimeTableScreen.routeName: (context) => TimeTableScreen(),
      },
    );
  }
}
