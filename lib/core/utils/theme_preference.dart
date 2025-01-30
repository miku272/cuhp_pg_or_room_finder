import 'package:shared_preferences/shared_preferences.dart';

class ThemePreference {
  static const _themeKey = 'theme';
  final SharedPreferences prefs;

  ThemePreference({required this.prefs});

  Future<bool> saveTheme(bool isDarkMode) async {
    return await prefs.setBool(_themeKey, isDarkMode);
  }

  bool loadTheme() {
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<bool> deleteTheme() async {
    return await prefs.remove(_themeKey);
  }
}
