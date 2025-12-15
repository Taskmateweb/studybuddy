import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedTheme = 'purple';
  double _fontSize = 14.0;

  bool get isDarkMode => _isDarkMode;
  String get selectedTheme => _selectedTheme;
  double get fontSize => _fontSize;

  final Map<String, Color> _themeColors = {
    'purple': const Color(0xFF667EEA),
    'blue': const Color(0xFF3B82F6),
    'green': const Color(0xFF10B981),
    'orange': const Color(0xFFF59E0B),
  };

  Color get primaryColor => _themeColors[_selectedTheme] ?? _themeColors['purple']!;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _selectedTheme = prefs.getString('theme') ?? 'purple';
    _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _selectedTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    notifyListeners();
  }

  ThemeData getThemeData() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: _fontSize + 2),
        bodyMedium: TextStyle(fontSize: _fontSize),
        bodySmall: TextStyle(fontSize: _fontSize - 2),
        titleLarge: TextStyle(fontSize: _fontSize + 8),
        titleMedium: TextStyle(fontSize: _fontSize + 4),
        titleSmall: TextStyle(fontSize: _fontSize + 2),
      ),
    );
  }
}
