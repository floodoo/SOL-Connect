import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData get lightTheme {
  final colors = AppColors.light();
  return ThemeData.light().copyWith(
    scaffoldBackgroundColor: colors.background,
    primaryColor: colors.primary,
    textTheme: ThemeData.light()
        .textTheme
        .copyWith(subtitle2: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400))),
  );
}
