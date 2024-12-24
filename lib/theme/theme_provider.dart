import 'package:flutter/material.dart';
import 'package:treehouse/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode(fontFamily: "Helvetica");

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  bool get isDarkMode => _themeData.brightness == Brightness.dark;

  void toggleTheme() {
    if (_themeData.brightness == Brightness.light) {
      themeData = darkMode(fontFamily: "Helvetica");
    } else {
      themeData = lightMode(fontFamily: "Helvetica");
    }
  }
}