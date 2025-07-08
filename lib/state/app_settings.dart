import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppSettings
/// Holds all app-wide settings and provides methods to load/save them
/// using SharedPreferences for persistence.
class AppSettings {
  // Whether passwords must be at least 12 characters
  bool twelveCharsEnabled = true;
  // Exclude ambiguous characters (O, 0, l, 1, I)
  bool excludeAmbiguous = false;
  // Hide the generated password in the UI
  bool hideGeneratedPassword = false;
  // Hide passwords in the password history
  bool hidePasswords = true;
  // Disallow repeating characters in passwords
  bool noRepeats = true;
  // Disallow sequential characters in passwords
  bool noSequences = true;
  // Enable/disable password history feature
  bool isPasswordHistoryOn = true;

  ThemeMode themeMode = ThemeMode.system;

  /// Loads all settings from persistent storage.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    twelveCharsEnabled = prefs.getBool('twelveCharsEnabled') ?? true;
    noRepeats = prefs.getBool('noRepeats') ?? true;
    noSequences = prefs.getBool('noSequences') ?? true;
    excludeAmbiguous = prefs.getBool('excludeAmbiguous') ?? false;
    hideGeneratedPassword = prefs.getBool('hideGeneratedPassword') ?? false;
    hidePasswords = prefs.getBool('hidePasswords') ?? true;
    isPasswordHistoryOn = prefs.getBool('isPasswordHistoryOn') ?? true;
    final themeString = prefs.getString('themeMode') ?? 'system';
    themeMode = _themeModeFromString(themeString);
  }

  /// Saves all settings to persistent storage.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('twelveCharsEnabled', twelveCharsEnabled);
    await prefs.setBool('noRepeats', noRepeats);
    await prefs.setBool('noSequences', noSequences);
    await prefs.setBool('excludeAmbiguous', excludeAmbiguous);
    await prefs.setBool('hideGeneratedPassword', hideGeneratedPassword);
    await prefs.setBool('hidePasswords', hidePasswords);
    await prefs.setBool('isPasswordHistoryOn', isPasswordHistoryOn);
    await prefs.setString('themeMode', themeModeToString(themeMode));
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    save();
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}