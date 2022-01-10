import 'package:flutter/material.dart';

class AppColors {
  const AppColors(
      {required this.primary,
      required this.background,
      required this.text,
      required this.textDark,
      required this.hintText,
      required this.error});

  final Color primary;
  final Color background;
  final Color text;
  final Color hintText;
  final Color textDark;
  final Color error;

  factory AppColors.light() {
    return AppColors(
        primary: Colors.red,
        background: Colors.amber.shade50,
        text: Colors.white,
        textDark: Colors.black,
        hintText: Colors.black38,
        error: Colors.red);
  }

  factory AppColors.dark() {
    return AppColors(
        primary: Colors.grey.shade900,
        background: Colors.black,
        text: Colors.white,
        textDark: Colors.black,
        hintText: Colors.white38,
        error: Colors.red);
  }
}
