import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      state = ThemeMode.values[themeIndex];
    } catch (e) {
      print('Error loading theme: $e');
      state = ThemeMode.light;
    }
  }

  Future<void> setTheme(ThemeMode theme) async {
    try {
      state = theme;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  void toggleTheme() {
    final newTheme =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setTheme(newTheme);
  }
}
