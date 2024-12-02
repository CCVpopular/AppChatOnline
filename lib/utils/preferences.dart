// Lưu và tải trạng thái theme bằng SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Preferences {
  static const _themeKey = 'theme_mode';

  // Lưu chế độ ThemeMode
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = mode.toString().split('.').last; // Chuyển ThemeMode thành "light", "dark", hoặc "system"
    prefs.setString(_themeKey, modeString);
  }

  // Tải chế độ ThemeMode
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeKey) ?? 'system'; // Mặc định là 'system'
    switch (modeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
