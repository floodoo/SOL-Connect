import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {

  bool showDeveloperOptions = false;
  String serverAddress = "flo-dev.me";

  void toggleDeveloperOptions() {
    showDeveloperOptions = showDeveloperOptions ? false : true;
    notifyListeners();
  }

  Future<void> saveServerAdress(String serverAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("serverAddress", serverAddress);
    this.serverAddress = serverAddress;
    notifyListeners();
  }

  void loadServerAdress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    serverAddress = prefs.getString("serverAddress") ?? "";
    notifyListeners();
  }
}
