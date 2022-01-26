import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sol_connect/ui/themes/app_colors.dart';

ThemeData get darkTheme {
  final colors = AppColors.dark();
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: colors.background,
    iconTheme: IconThemeData(color: colors.text),
    primaryColor: colors.primary,
    textTheme: ThemeData.dark().textTheme.copyWith(
          subtitle2: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
  );
}
