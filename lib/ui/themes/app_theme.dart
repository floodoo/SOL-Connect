import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'dark.theme.dart';
import 'light.theme.dart';

class AppTheme {
  AppTheme({required this.data, required this.mode, required this.colors});

  final ThemeData data;
  final ThemeMode mode;
  final AppColors colors;

  factory AppTheme.light() => AppTheme(data: lightTheme, mode: ThemeMode.light, colors: AppColors.light());

  factory AppTheme.dark() => AppTheme(data: darkTheme, mode: ThemeMode.dark, colors: AppColors.dark());
}
