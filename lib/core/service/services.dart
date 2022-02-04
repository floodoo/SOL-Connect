import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/service/settings.service.dart';
import 'package:sol_connect/core/service/teacher.service.dart';
import 'package:sol_connect/core/service/theme.service.dart';
import 'package:sol_connect/core/service/time_table.service.dart';

final themeService = ChangeNotifierProvider<ThemeService>((ref) => ThemeService());
final timeTableService = ChangeNotifierProvider<TimeTableService>((ref) => TimeTableService());
final settingsService = ChangeNotifierProvider<SettingsService>((ref) => SettingsService());
final teacherService = ChangeNotifierProvider<TeacherService>((ref) => TeacherService());
