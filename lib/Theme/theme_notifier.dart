// Quản lý trạng thái chế độ theme (Provider)
import 'package:flutter/material.dart';
import '../utils/preferences.dart'; // Lưu trạng thái theme

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    Preferences.saveThemeMode(mode); // Lưu trạng thái theme
    notifyListeners();
  }

  Future<void> _loadThemeMode() async {
    _themeMode = await Preferences.loadThemeMode(); // Tải trạng thái theme
    notifyListeners();
  }
}
