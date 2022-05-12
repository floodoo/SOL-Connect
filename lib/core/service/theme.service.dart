import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      var brightness = SchedulerBinding.instance.window.platformBrightness;
      bool lightMode = prefs.getBool("lightMode") ?? brightness == Brightness.light;
      prefs.setBool("lightMode", lightMode);
      _theme = lightMode ? AppTheme.light() : AppTheme.dark();
      loaded = true;
      notifyListeners();
    }
  }
}
