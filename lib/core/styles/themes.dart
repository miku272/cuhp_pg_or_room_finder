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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        side: const BorderSide(color: AppColors.lightPrimary),
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurface,
      disabledColor: Colors.grey.withValues(alpha: 0.5),
      selectedColor: AppColors.lightPrimary,
      secondarySelectedColor: AppColors.lightSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: GoogleFonts.roboto(color: AppColors.lightOnSurface),
      secondaryLabelStyle: GoogleFonts.roboto(color: AppColors.lightOnPrimary),
      brightness: Brightness.light,
      shape: const StadiumBorder(),
      side: const BorderSide(color: AppColors.lightDivider),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      hintStyle: GoogleFonts.roboto(
          color: AppColors.lightOnSurface.withValues(
        alpha: 0.6,
      )),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightError, width: 2),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.lightPrimary,
      inactiveTrackColor: AppColors.lightPrimary.withValues(alpha: 0.3),
      thumbColor: AppColors.lightPrimary,
      overlayColor: AppColors.lightPrimary.withValues(alpha: 0.2),
      valueIndicatorColor: AppColors.lightPrimary,
      valueIndicatorTextStyle:
          GoogleFonts.roboto(color: AppColors.lightOnPrimary),
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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        side: const BorderSide(color: AppColors.darkPrimary),
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      disabledColor: Colors.grey.withValues(alpha: 0.5),
      selectedColor: AppColors.darkPrimary,
      secondarySelectedColor: AppColors.darkSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: GoogleFonts.roboto(color: AppColors.darkOnSurface),
      secondaryLabelStyle: GoogleFonts.roboto(color: AppColors.darkOnPrimary),
      brightness: Brightness.dark,
      shape: const StadiumBorder(),
      side: const BorderSide(color: AppColors.darkDivider),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      hintStyle: GoogleFonts.roboto(
          color: AppColors.darkOnSurface.withValues(alpha: 0.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkError, width: 2),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.darkPrimary,
      inactiveTrackColor: AppColors.darkPrimary.withValues(alpha: 0.3),
      thumbColor: AppColors.darkPrimary,
      overlayColor: AppColors.darkPrimary.withValues(alpha: 0.2),
      valueIndicatorColor: AppColors.darkPrimary,
      valueIndicatorTextStyle:
          GoogleFonts.roboto(color: AppColors.darkOnPrimary),
    ),
    dividerColor: AppColors.darkDivider,
  );
}
