import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.primary,
    required this.background,
    required this.text,
    required this.textBackground,
    required this.hintText,
    required this.error,
    required this.circleAvatar,
    required this.progressIndicator,
    required this.icon,
    // Phase colors
    required this.phaseFree,
    required this.phaseOrienting,
    required this.phaseReflection,
    required this.phaseStructured,
    required this.phaseFeedback,
    required this.phaseUnknown,
  });

  final Color primary;
  final Color background;
  final Color text;
  final Color textBackground;
  final Color hintText;
  final Color error;
  final Color circleAvatar;
  final Color progressIndicator;
  final Color icon;
  // Phase colors
  final Color phaseFree;
  final Color phaseOrienting;
  final Color phaseReflection;
  final Color phaseStructured;
  final Color phaseFeedback;
  final Color phaseUnknown;

  factory AppColors.light() {
    return AppColors(
      primary: Colors.red.shade800,
      background: Colors.white,
      text: Colors.white,
      textBackground: Colors.black,
      hintText: Colors.black38,
      error: Colors.red.shade800,
      circleAvatar: Colors.black87,
      progressIndicator: Colors.red.shade800,
      icon: Colors.white,
      // Phase colors
      phaseFree: Colors.green,
      phaseOrienting: Colors.orange,
      phaseReflection: Colors.yellow,
      phaseStructured: Colors.blue,
      phaseFeedback: Colors.red,
      phaseUnknown: Colors.grey,
    );
  }

  factory AppColors.dark() {
    return AppColors(
      primary: Colors.grey.shade900,
      background: Colors.blueGrey.shade900,
      text: Colors.white,
      textBackground: Colors.white,
      hintText: Colors.white38,
      error: Colors.red.shade800,
      circleAvatar: Colors.white,
      progressIndicator: Colors.white,
      icon: Colors.white,
      // Phase color
      phaseFree: Colors.green,
      phaseOrienting: Colors.orange,
      phaseReflection: Colors.yellow,
      phaseStructured: Colors.blue,
      phaseFeedback: Colors.red,
      phaseUnknown: Colors.blueGrey.shade700,
    );
  }
}
