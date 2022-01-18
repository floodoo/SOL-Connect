import 'package:flutter/material.dart';
import 'package:untis_phasierung/ui/themes/app_colors.dart';
import 'package:untis_phasierung/ui/themes/dark.theme.dart';
import 'package:untis_phasierung/ui/themes/light.theme.dart';

class AppTheme {
  AppTheme({required this.data, required this.mode, required this.colors});

  final ThemeData data;
  final ThemeMode mode;
  final AppColors colors;

  factory AppTheme.light() => AppTheme(data: lightTheme, mode: ThemeMode.light, colors: AppColors.light());

  factory AppTheme.dark() => AppTheme(data: darkTheme, mode: ThemeMode.dark, colors: AppColors.dark());
}
