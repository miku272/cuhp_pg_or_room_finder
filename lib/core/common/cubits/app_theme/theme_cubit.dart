import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/theme_preference.dart';

import '../../../styles/themes.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemePreference prefs;

  ThemeCubit({required this.prefs})
      : super(LightThemeState(AppThemes.lightTheme)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDarkMode = await prefs.loadTheme();

    isDarkMode
        ? emit(DarkThemeState(AppThemes.darkTheme))
        : emit(LightThemeState(AppThemes.lightTheme));
  }

  void toggleTheme() {
    if (state is LightThemeState) {
      emit(DarkThemeState(AppThemes.darkTheme));
      prefs.saveTheme(true);
    } else {
      emit(LightThemeState(AppThemes.lightTheme));
      prefs.saveTheme(false);
    }
  }
}
