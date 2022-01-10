import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.primary,
    required this.background,
    required this.text,
    required this.hintText,
    required this.error
  });

  final Color primary;
  final Color background;
  final Color text;
  final Color hintText;
  final Color error;

  factory AppColors.light() {
    return AppColors(
      primary: Colors.red,
      background: Colors.amber.shade50,
      text: Colors.black,
      hintText: Colors.black38,
      error: Colors.redAccent
    );
  }

  factory AppColors.dark() {
    return AppColors(
      primary: Colors.grey.shade900,
      background: Colors.black,
      text: Colors.white,
      hintText: Colors.white38,
      error: Colors.redAccent
    );
  }
}
