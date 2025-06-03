import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treehouse/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _themeData;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  bool get isDarkMode => _themeData.brightness == Brightness.dark;

  Future<void> toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_themeData.brightness == Brightness.light) {
      _themeData = darkMode(fontFamily: "Helvetica");
      await prefs.setBool('isDarkMode', true);
    } else {
      _themeData = lightMode(fontFamily: "Helvetica");
      await prefs.setBool('isDarkMode', false);
    }

    notifyListeners();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;

    _themeData = isDark
        ? darkMode(fontFamily: "Helvetica")
        : lightMode(fontFamily: "Helvetica");

    notifyListeners();
  }
}
