// providers/calendar_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CalendarType {
  gregorian,
  ethiopian,
}

class CalendarSettings {
  final CalendarType calendarType;
  final double fontSizeScale;

  const CalendarSettings({
    this.calendarType = CalendarType.gregorian,
    this.fontSizeScale = 1.0,
  });

  CalendarSettings copyWith({
    CalendarType? calendarType,
    double? fontSizeScale,
  }) {
    return CalendarSettings(
      calendarType: calendarType ?? this.calendarType,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calendar_type': calendarType.name,
      'font_size_scale': fontSizeScale,
    };
  }

  factory CalendarSettings.fromMap(Map<String, dynamic> map) {
    return CalendarSettings(
      calendarType: CalendarType.values.firstWhere(
        (e) => e.name == map['calendar_type'],
        orElse: () => CalendarType.gregorian,
      ),
      fontSizeScale: map['font_size_scale']?.toDouble() ?? 1.0,
    );
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarSettings>(
  (ref) => CalendarNotifier(),
);

class CalendarNotifier extends StateNotifier<CalendarSettings> {
  CalendarNotifier() : super(const CalendarSettings()) {
    _loadSettings();
  }

  static const String _settingsKey = 'calendar_settings';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString(_settingsKey);

      if (settingsString != null && settingsString.isNotEmpty) {
        try {
          final settingsMap =
              Map<String, dynamic>.from(json.decode(settingsString));
          state = CalendarSettings.fromMap(settingsMap);
        } catch (e) {
          print('Error parsing calendar settings: $e');
          // Fallback to default settings
          final calendarIndex = prefs.getInt('preferred_calendar') ?? 0;
          state = CalendarSettings(
            calendarType: CalendarType.values[calendarIndex],
            fontSizeScale: 1.0,
          );
        }
      } else {
        // Legacy support for old preference format
        final calendarIndex = prefs.getInt('preferred_calendar') ?? 0;
        state = CalendarSettings(
          calendarType: CalendarType.values[calendarIndex],
          fontSizeScale: 1.0,
        );
      }
    } catch (e) {
      print('Error loading calendar settings: $e');
      state = const CalendarSettings();
    }
  }

  Future<void> setCalendarType(CalendarType type) async {
    state = state.copyWith(calendarType: type);
    await _saveSettings();
  }

  Future<void> setFontSizeScale(double scale) async {
    state = state.copyWith(fontSizeScale: scale.clamp(0.8, 1.5));
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, json.encode(state.toMap()));
      // Also save legacy format for compatibility
      await prefs.setInt('preferred_calendar', state.calendarType.index);
    } catch (e) {
      print('Error saving calendar settings: $e');
    }
  }
}
