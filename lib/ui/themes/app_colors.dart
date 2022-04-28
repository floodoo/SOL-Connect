import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.primary,
    required this.timetableBackground,
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
    required this.phaseOutOfBounds,
    required this.phaseNotStartet,
    required this.phaseActive,
    required this.phaseNotUploadedJet,

    // Phase colors
    required this.phaseFree,
    required this.phaseOrienting,
    required this.phaseReflection,
    required this.phaseStructured,
    required this.phaseFeedback,
    required this.phaseUnknown,
    required this.phaseOutOfBlock,
    required this.phaseOrientingDisabled,
    required this.phaseReflectionDisabled,
    required this.phaseStructuredDisabled,
    required this.phaseFreeDisabled,
    required this.phaseFeedbackDisabled,
    required this.phaseUnknownDisabled,
    // Status colors
    required this.irregular,
    required this.cancelled,
    required this.noTeacher,
  });

  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color timetableBackground;
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
  final Color phaseFreeDisabled;
  final Color phaseOrientingDisabled;
  final Color phaseReflectionDisabled;
  final Color phaseStructuredDisabled;
  final Color phaseFeedbackDisabled;
  final Color phaseUnknownDisabled;

  final Color phaseOutOfBounds;
  final Color phaseNotStartet;
  final Color phaseActive;
  final Color phaseNotUploadedJet;

  final Color phaseOutOfBlock;
  // Status colors
  final Color irregular;
  final Color cancelled;
  final Color noTeacher;

  factory AppColors.light() {
    return AppColors(
      primary: const Color.fromARGB(255, 14, 120, 240),
      primaryLight: Colors.red.shade500,
      background: const Color.fromARGB(255, 225, 225, 230),
      timetableBackground: const Color.fromARGB(255, 201, 201, 211),
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
      loginBackgroundGradient1: const Color.fromARGB(255, 13, 43, 177),
      loginBackgroundGradient2: const Color.fromARGB(255, 15, 39, 148),
      timetableCardBackground: Colors.grey.shade800,
      timetableCardEdge: const Color.fromARGB(255, 255, 255, 255),
      // Phase colors
      phaseFree: Colors.green.shade700,
      phaseOrienting: Colors.orange.shade700,
      phaseReflection: Colors.yellow.shade700,
      phaseStructured: Colors.blue.shade700,
      phaseFeedback: Colors.blue.shade700,
      phaseUnknown: Colors.grey,
      phaseOutOfBlock: Colors.red.shade300,
      phaseFreeDisabled: Colors.green.shade800,
      phaseOrientingDisabled: const Color(0xffde9f5f),
      phaseReflectionDisabled: const Color(0xffdec573),
      phaseStructuredDisabled: const Color(0xff5e6591),
      phaseFeedbackDisabled: const Color(0xffcf7070),
      phaseUnknownDisabled: Colors.grey.shade700,
      phaseOutOfBounds: Colors.red.shade700,
      phaseNotStartet: Colors.green.shade300,
      phaseActive: Colors.green.shade700,
      phaseNotUploadedJet: Colors.grey,
      // Status colors
      irregular: const Color(0xffa545b5),
      cancelled: const Color(0xffa80c0c),
      noTeacher: const Color.fromARGB(255, 144, 77, 155),
    );
  }

  factory AppColors.dark() {
    return AppColors(
        primary: Colors.grey.shade900,
        primaryLight: Colors.grey.shade800,
        background: const Color(0xff2b2e36),
        timetableBackground: const Color(0xff2b2e36),
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
        phaseFreeDisabled: const Color(0xff142D15),
        phaseOrientingDisabled: const Color(0xff63401C),
        phaseReflectionDisabled: const Color(0xff635636),
        phaseStructuredDisabled: const Color(0xff06213B),
        phaseFeedbackDisabled: const Color(0xff380808),
        phaseUnknownDisabled: Colors.grey.shade700,
        phaseUnknown: Colors.blueGrey.shade700,
        phaseOutOfBlock: Colors.red.shade900,
        phaseFree: Colors.green.shade700,
        phaseOrienting: Colors.orange.shade700,
        phaseReflection: Colors.yellow.shade700,
        phaseStructured: Colors.blue.shade700,
        phaseFeedback: Colors.red.shade700,

        //Uploadedphasecolors
        phaseOutOfBounds: Colors.red.shade700,
        phaseNotStartet: Colors.green.shade300,
        phaseActive: Colors.green.shade700,
        phaseNotUploadedJet: Colors.grey,

        // Status colors
        irregular: const Color(0xffCB67DC),
        cancelled: const Color(0xffE2222B),
        noTeacher: const Color(0xffCB67DC));
  }
}
