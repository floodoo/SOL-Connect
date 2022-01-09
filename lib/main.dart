import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';
import 'package:logger/logger.dart';
import 'package:untis_phasierung/ui/screens/login/login.screen.dart';

void main() {
  Logger.level = Level.debug;
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(timeTableService).getUserData();
    return MaterialApp(
      title: "Untis phasierung",
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        CustomDrawer.routeName: (context) => const CustomDrawer(),
        TimeTableScreen.routeName: (context) => const TimeTableScreen(),
      },
    );
  }
}
