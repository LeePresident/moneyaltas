import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing the current theme mode.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themePrefKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// Load the stored theme preference from SharedPreferences.
  /// If no preference is saved, defaults to [ThemeMode.system].
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_themePrefKey);
      
      if (themeName != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeName,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      state = ThemeMode.system;
    }
  }

  /// Toggle between light, dark, and system themes.
  Future<void> toggleTheme() async {
    final newMode = _getNextThemeMode(state);
    await setThemeMode(newMode);
  }

  /// Set the theme to a specific mode and persist it.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Cycle through theme modes: system -> light -> dark -> system
  static ThemeMode _getNextThemeMode(ThemeMode current) {
    switch (current) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }

  /// Get a display string for the current theme mode.
  static String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  /// Get the icon for the current theme mode.
  static IconData getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.settings_brightness;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}
