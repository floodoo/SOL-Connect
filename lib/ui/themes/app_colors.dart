import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.elementBackground,
    required this.errorBackground,
    required this.text,
    required this.textBackground,
    required this.textInverted,
    required this.hintText,
    required this.error,
    required this.circleAvatar,
    required this.progressIndicator,
    required this.icon,
    required this.successColor,
    required this.loginBackgroundGradient1,
    required this.loginBackgroundGradient2,
    required this.textLight,
    required this.textLightInverted,
    required this.timetableCardBackground,
    required this.timetableCardEdge,

    // Phase colors
    required this.phaseFree,
    required this.phaseOrienting,
    required this.phaseReflection,
    required this.phaseStructured,
    required this.phaseFeedback,
    required this.phaseUnknown,
    required this.phaseOutOfBlock,
    // Status colors
    required this.irregular,
    required this.cancelled,
    required this.noTeacher,
  });

  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color elementBackground;
  final Color errorBackground;
  final Color text;
  final Color textBackground;
  final Color textInverted;
  final Color hintText;
  final Color error;
  final Color circleAvatar;
  final Color progressIndicator;
  final Color icon;
  final Color successColor;
  final Color loginBackgroundGradient1;
  final Color loginBackgroundGradient2;
  final Color textLight;
  final Color textLightInverted;
  final Color
      timetableCardBackground; //Dunkle Kacheln des Stundenplanes. Haupsächlich wenn keine Phasierung geladen ist
  final Color timetableCardEdge; //Kanten des Stundenplanes
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
  final Color noTeacher;

  factory AppColors.light() {
    return AppColors(
        primary: Colors.red.shade900,
        primaryLight: Colors.red.shade500,
        background: Colors.white,
        elementBackground: Colors.grey.shade600,
        errorBackground: Colors.red.shade900,
        text: Colors.white,
        textLight: Colors.grey.shade300,
        textLightInverted: Colors.grey.shade800,
        textBackground: Colors.black,
        textInverted: Colors.black,
        hintText: Colors.black38,
        error: Colors.red.shade800,
        circleAvatar: Colors.black87,
        progressIndicator: Colors.red.shade800,
        icon: Colors.white,
        successColor: Colors.green.shade600,
        loginBackgroundGradient1: const Color(0xff96250f),
        loginBackgroundGradient2: const Color(0xff750c0c),
        timetableCardBackground: Colors.grey.shade800,
        timetableCardEdge: Colors.grey.shade700,
        // Phase colors
        phaseFree: Colors.green.shade700,
        phaseOrienting: Colors.orange.shade700,
        phaseReflection: Colors.yellow.shade700,
        phaseStructured: Colors.blue.shade700,
        phaseFeedback: Colors.red.shade700,
        phaseUnknown: Colors.grey,
        phaseOutOfBlock: Colors.red.shade300,
        // Status colors
        irregular: Colors.blue.shade900,
        cancelled: const Color(0xffa545b5),
        noTeacher: const Color(0xffa545b5));
  }

  factory AppColors.dark() {
    return AppColors(
        primary: Colors.grey.shade900,
        primaryLight: Colors.grey.shade800,
        background: const Color(0xff2b2e36),
        elementBackground: Colors.black,
        errorBackground: Colors.red.shade900,
        text: Colors.white,
        textLight: Colors.grey.shade300,
        textLightInverted: Colors.grey.shade300,
        textBackground: Colors.white,
        textInverted: Colors.white,
        hintText: Colors.white38,
        error: Colors.red.shade800,
        circleAvatar: Colors.white,
        progressIndicator: Colors.white,
        icon: Colors.white,
        successColor: Colors.green.shade800,
        loginBackgroundGradient2: const Color(0xff181721),
        loginBackgroundGradient1: const Color(0xff252426),
        timetableCardBackground: Colors.grey.shade900,
        timetableCardEdge: Colors.grey.shade800,
        // Phase color
        phaseFree: Colors.green.shade700,
        phaseOrienting: Colors.orange.shade700,
        phaseReflection: Colors.yellow.shade700,
        phaseStructured: Colors.blue.shade700,
        phaseFeedback: Colors.red.shade700,
        phaseUnknown: Colors.blueGrey.shade700,
        phaseOutOfBlock: Colors.red.shade900,
        // Status colors
        irregular: Colors.blue.shade900,
        cancelled: const Color(0xffa545b5),
        noTeacher: const Color(0xffa545b5));
  }
}
