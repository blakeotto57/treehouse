import 'package:flutter/material.dart';

ThemeData lightMode({String? fontFamily}) {
  return ThemeData(
    brightness: Brightness.light,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.light(
      surface: Colors.grey.shade100,
      primary: Colors.grey.shade200,
      secondary: Colors.grey.shade600,
    ),
  );
}

ThemeData darkMode({String? fontFamily}) {
  return ThemeData(
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.dark(
      surface: Colors.grey.shade900,
      primary: Colors.grey.shade800,
      secondary: Colors.grey.shade700,
    ),
  );
}