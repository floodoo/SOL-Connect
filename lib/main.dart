import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/notification.service.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/settings/settings.screen.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/time_table_detail.screen.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';
import 'package:logger/logger.dart';
import 'package:untis_phasierung/ui/screens/login/login.screen.dart';

Future<void> main() async {
  Logger.level = Level.debug;
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
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
