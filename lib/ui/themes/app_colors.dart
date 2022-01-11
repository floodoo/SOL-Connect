import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.primary,
    required this.background,
    required this.text,
    required this.hintText,
    required this.error,
    required this.circleAvatar,
    required this.icon,
    // Phase colors
    required this.phaseFree,
    required this.phaseOrienting,
    required this.phaseReflection,
    required this.phaseStructured,
    required this.phaseFeedback
  });

  final Color primary;
  final Color background;
  final Color text;
  final Color hintText;
  final Color error;
  final Color circleAvatar;
  final Color icon;
  // Phase colors
  final Color phaseFree;
  final Color phaseOrienting;
  final Color phaseReflection;
  final Color phaseStructured;
  final Color phaseFeedback;

  factory AppColors.light() {
    return AppColors(
      primary: Colors.orange.shade400,
      background: Colors.grey.shade300,
      text: Colors.black,
      hintText: Colors.black38,
      error: Colors.red.shade800,
      circleAvatar: Colors.white,
      icon: Colors.black,
      // Phase colors
      phaseFree: Colors.green.shade300,
      phaseOrienting: Colors.orange.shade300,
      phaseReflection: Colors.blue.shade300,
      phaseStructured: Colors.purple.shade300,
      phaseFeedback: Colors.red.shade300,
    );
  }

  factory AppColors.dark() {
    return AppColors(
      primary: Colors.grey.shade900,
      background: Colors.black,
      text: Colors.white,
      hintText: Colors.white38,
      error: Colors.red.shade800,
      circleAvatar: Colors.white,
      icon: Colors.white,
      // Phase color
      phaseFree: Colors.green.shade300,
      phaseOrienting: Colors.orange.shade300,
      phaseReflection: Colors.blue.shade300,
      phaseStructured: Colors.purple.shade300,
      phaseFeedback: Colors.red.shade300,
    );
  }
}
