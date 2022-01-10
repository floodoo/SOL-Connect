import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.primary,
    required this.background,
    required this.text,
    required this.textDark,
    required this.hintText,
    required this.error,
    required this.circleAvatar,
  });

  final Color primary;
  final Color background;
  final Color text;
  final Color hintText;
  final Color textDark;
  final Color error;
  final Color circleAvatar;

  factory AppColors.light() {
    return AppColors(
      primary: Colors.orange.shade600,
      background: Colors.blueGrey.shade200,
      text: Colors.white,
      textDark: Colors.black,
      hintText: Colors.black38,
      error: Colors.red,
      circleAvatar: Colors.white,
    );
  }

  factory AppColors.dark() {
    return AppColors(
      primary: Colors.grey.shade900,
      background: Colors.black,
      text: Colors.white,
      textDark: Colors.black,
      hintText: Colors.white38,
      error: Colors.red,
      circleAvatar: Colors.white,
    );
  }
}
