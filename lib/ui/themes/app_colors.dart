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
    required this.irregular,
    required this.cancelled,
    required this.elementBackground,
    required this.errorBackground,
    required this.textInverted,
    required this.successColor,
    required this.primaryLight,
    required this.phaseOutOfBlock,
  });

  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color elementBackground;
  final Color text;
  final Color textBackground;
  final Color hintText;
  final Color error;
  final Color circleAvatar;
  final Color progressIndicator;
  final Color icon;
  final Color errorBackground;
  final Color textInverted; //Umgedreht zum mode: light -> schwarz, dark -> weiß
  final Color successColor;
  // Phase colors
  final Color phaseFree;
  final Color phaseOrienting;
  final Color phaseReflection;
  final Color phaseStructured;
  final Color phaseFeedback;
  final Color phaseUnknown;
  final Color phaseOutOfBlock;
  // Status colors
  final Color irregular;
  final Color cancelled;

  factory AppColors.light() {
    return AppColors(
      primary: Colors.red.shade900,
      primaryLight: Colors.red.shade500,
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
      elementBackground: Colors.grey.shade600,
      errorBackground: Colors.red.shade900,
      textInverted: Colors.black,
      phaseOutOfBlock: Colors.red.shade300,
      successColor: Colors.green.shade600,
      // Status colors
      irregular: Colors.deepPurple.shade900,
      cancelled: Colors.purpleAccent,
    );
  }

  factory AppColors.dark() {
    return AppColors(
      primary: Colors.grey.shade900,
      primaryLight: Colors.grey.shade800,
      background: Colors.blueGrey.shade900,
      text: Colors.white,
      textInverted: Colors.white,
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
      elementBackground: Colors.black,
      errorBackground: Colors.red.shade900,
      phaseOutOfBlock: Colors.red.shade900,
      successColor: Colors.green.shade800,
      // Status colors
      irregular: Colors.deepPurple.shade900,
      cancelled: Colors.purpleAccent,
    );
  }
}
