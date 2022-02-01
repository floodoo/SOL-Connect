import 'package:flutter/material.dart';

class TeacherService with ChangeNotifier {
  bool isReloading = false;

  Future<void> toggleReloading() async {
    isReloading = true;
    notifyListeners();
    isReloading = false;
    notifyListeners();
  }
}
