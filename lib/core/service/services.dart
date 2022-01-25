import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/settings.service.dart';
import 'package:untis_phasierung/core/service/theme.service.dart';
import 'package:untis_phasierung/core/service/time_table.service.dart';

final themeService = ChangeNotifierProvider<ThemeService>((ref) => ThemeService());
final timeTableService = ChangeNotifierProvider<TimeTableService>((ref) => TimeTableService());
final settingsService = ChangeNotifierProvider<SettingsService>((ref) => SettingsService());
