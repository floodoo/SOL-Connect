import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untis_phasierung/ui/themes/app_theme.dart';

class ThemeService with ChangeNotifier {
  AppTheme _theme = AppTheme.light();

  AppTheme get theme => _theme;
  bool loaded = false;

  void toggle() {
    _theme = _theme.mode == ThemeMode.light ? AppTheme.dark() : AppTheme.light();
    notifyListeners();
  }

  Future<void> saveAppearence(bool lightMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("lightMode", lightMode);
    toggle();
  }

  void loadAppearence() async {
    if (loaded == false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool lightMode = prefs.getBool("lightMode") ?? true;
      _theme = lightMode ? AppTheme.light() : AppTheme.dark();
      loaded = true;
      notifyListeners();
    }
  }
}
