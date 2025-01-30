import 'package:flutter/material.dart';

abstract class ThemeState {
  bool get isDarkMode;
}

class LightThemeState extends ThemeState {
  final ThemeData themeData;

  @override
  bool get isDarkMode => false;

  LightThemeState(this.themeData);
}

class DarkThemeState extends ThemeState {
  final ThemeData themeData;

  @override
  bool get isDarkMode => true;

  DarkThemeState(this.themeData);
}
