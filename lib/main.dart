import 'package:flutter/material.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';
import 'package:untis_phasierung/ui/screens/login/login.screen.dart';
import 'package:untis_phasierung/ui/screens/timetable/timetable.screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        CustomDrawer.routeName: (context) => const CustomDrawer(),
        TimetableScreen.routeName: (context) => const TimetableScreen(),
      },
    );
  }
}
