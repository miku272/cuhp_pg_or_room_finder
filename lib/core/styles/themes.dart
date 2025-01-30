import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      // background: AppColors.lightBackground,
      error: AppColors.lightError,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnSecondary,
      onSurface: AppColors.lightOnSurface,
      // onBackground: AppColors.lightOnBackground,
      onError: AppColors.lightOnError,
    ),
    appBarTheme: AppBarTheme(
      color: AppColors.lightPrimary,
      iconTheme: const IconThemeData(color: AppColors.lightOnPrimary),
      titleTextStyle: GoogleFonts.roboto(
        color: AppColors.lightOnPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.roboto(
        color: AppColors.lightOnBackground,
        fontSize: 16,
      ),
      titleLarge: GoogleFonts.roboto(
        color: AppColors.lightOnBackground,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerColor: AppColors.lightDivider,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      // background: AppColors.darkBackground,
      error: AppColors.darkError,
      onPrimary: AppColors.darkOnPrimary,
      onSecondary: AppColors.darkOnSecondary,
      onSurface: AppColors.darkOnSurface,
      // onBackground: AppColors.darkOnBackground,
      onError: AppColors.darkOnError,
    ),
    appBarTheme: AppBarTheme(
      color: AppColors.darkPrimary,
      iconTheme: const IconThemeData(color: AppColors.darkOnPrimary),
      titleTextStyle: GoogleFonts.roboto(
        color: AppColors.darkOnPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.roboto(
        color: AppColors.darkOnBackground,
        fontSize: 16,
      ),
      titleLarge: GoogleFonts.roboto(
        color: AppColors.darkOnBackground,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerColor: AppColors.darkDivider,
  );
}
