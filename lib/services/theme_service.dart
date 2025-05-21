import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  static const String _themeColorKey = 'themeColor';
  static const String _defaultThemeColor = 'Indigo';

  bool _darkMode = false;
  String _themeColor = _defaultThemeColor;
  
  // Theme color options
  static const Map<String, Color> themeColors = {
    'Indigo': Color(0xFF6366F1),
    'Blue': Color(0xFF3B82F6),
    'Teal': Color(0xFF14B8A6),
    'Purple': Color(0xFF8B5CF6),
    'Orange': Color(0xFFF97316),
  };

  ThemeService() {
    _loadPreferences();
  }

  bool get darkMode => _darkMode;
  String get themeColor => _themeColor;
  
  // Get the primary color based on the selected theme
  Color get primaryColor => themeColors[_themeColor] ?? themeColors[_defaultThemeColor]!;
  
  // Get the secondary color (a lighter shade of the primary color)
  Color get secondaryColor {
    final primaryColor = themeColors[_themeColor] ?? themeColors[_defaultThemeColor]!;
    return Color.lerp(primaryColor, Colors.white, 0.3) ?? primaryColor;
  }
  
  // Get the theme data based on the current settings
  ThemeData getThemeData() {
    final baseTheme = _darkMode ? ThemeData.dark() : ThemeData.light();
    final primaryColor = themeColors[_themeColor] ?? themeColors[_defaultThemeColor]!;
    
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: _darkMode ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    _themeColor = prefs.getString(_themeColorKey) ?? _defaultThemeColor;
    notifyListeners();
  }

  // Set dark mode
  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;
    
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  // Set theme color
  Future<void> setThemeColor(String value) async {
    if (_themeColor == value) return;
    
    _themeColor = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeColorKey, value);
    notifyListeners();
  }
  
  // Reset all theme settings to defaults
  Future<void> resetTheme() async {
    _darkMode = false;
    _themeColor = _defaultThemeColor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, false);
    await prefs.setString(_themeColorKey, _defaultThemeColor);
    notifyListeners();
  }
}
