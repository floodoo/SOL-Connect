import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/login/login.screen.dart';
import 'package:sol_connect/ui/screens/settings/settings.screen.dart';
import 'package:sol_connect/ui/screens/time_table/time_table.screen.dart';
import 'package:sol_connect/ui/screens/time_table_detail/time_table_detail.screen.dart';
import 'package:sol_connect/ui/shared/custom_drawer.dart';

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
    final theme = ref.watch(themeService).theme;
    ref.read(themeService).loadAppearence();
    ref.read(timeTableService).getSchoolName();
    ref.read(timeTableService).getUserData();

    return MaterialApp(
      title: "Untis phasierung",
      theme: theme.data,
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        CustomDrawer.routeName: (context) => const CustomDrawer(),
        TimeTableScreen.routeName: (context) => const TimeTableScreen(),
        TimeTableDetailScreen.routeName: (context) => const TimeTableDetailScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
      },
    );
  }
}
