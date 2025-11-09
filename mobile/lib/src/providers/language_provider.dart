import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en', 'US')) {
    _loadLanguage();
  }

  static const String _languageKey = 'app_language';

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      state = Locale(languageCode);
    } catch (e) {
      print('Error loading language: $e');
      state = const Locale('en');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      state = Locale(languageCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  void toggleLanguage() {
    final newLanguage = state.languageCode == 'en' ? 'am' : 'en';
    setLanguage(newLanguage);
  }

  String get currentLanguage => state.languageCode;

  bool get isEnglish => state.languageCode == 'en';
  bool get isAmharic => state.languageCode == 'am';
}
