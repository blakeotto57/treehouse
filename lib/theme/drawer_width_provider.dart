import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidthProvider with ChangeNotifier {
  static const double _defaultWidth = 220.0;
  static const double _minWidth = 180.0;
  static const double _maxWidth = 400.0;
  static const String _widthKey = 'drawer_width';

  double _drawerWidth = _defaultWidth;
  bool _isInitialized = false;

  DrawerWidthProvider() {
    _loadWidth();
  }

  double get drawerWidth => _drawerWidth;
  double get minWidth => _minWidth;
  double get maxWidth => _maxWidth;

  Future<void> _loadWidth() async {
    if (_isInitialized) return;
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final savedWidth = prefs.getDouble(_widthKey);
      if (savedWidth != null) {
        _drawerWidth = savedWidth.clamp(_minWidth, _maxWidth);
      } else {
        _drawerWidth = _defaultWidth;
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _drawerWidth = _defaultWidth;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setDrawerWidth(double width) async {
    final clampedWidth = width.clamp(_minWidth, _maxWidth);
    if (_drawerWidth == clampedWidth) return;

    _drawerWidth = clampedWidth;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_widthKey, _drawerWidth);
    } catch (e) {
      // Silently fail if we can't save
    }
  }

  Future<void> resetDrawerWidth() async {
    await setDrawerWidth(_defaultWidth);
  }
}

