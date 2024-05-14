import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveToPrefs(mode);
  }

  Future<void> _saveToPrefs(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', mode == ThemeMode.dark);
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
        (prefs.getBool('darkMode') ?? true) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
