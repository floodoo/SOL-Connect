import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sol_connect/ui/themes/app_theme.dart';

class ThemeService with ChangeNotifier {
  AppTheme _theme = AppTheme.dark();

  AppTheme get theme => _theme;
  bool loaded = false;

  void toggleTheming() {
    _theme = _theme.mode == ThemeMode.light ? AppTheme.dark() : AppTheme.light();
    notifyListeners();
  }

  Future<void> saveAppearence(bool lightMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("lightMode", lightMode);
    toggleTheming();
  }

  void loadAppearence() async {
    if (loaded == false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool lightMode = prefs.getBool("lightMode") ?? false;
      _theme = lightMode ? AppTheme.light() : AppTheme.dark();
      loaded = true;
      notifyListeners();
    }
  }
}
