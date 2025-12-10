// src/utils/calendar_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum CalendarType {
  gregorian('Gregorian', 'ግሪጎርያን'),
  ethiopian('Ethiopian', 'ኢትዮጵያዊ');

  final String englishName;
  final String amharicName;

  const CalendarType(this.englishName, this.amharicName);
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

// Ethiopian Date Implementation
class EthiopianDateTime {
  final int year;
  final int month;
  final int day;

  EthiopianDateTime(
      {required this.year, required this.month, required this.day});

  // Convert Gregorian to Ethiopian date
  // This is a simplified conversion algorithm
  factory EthiopianDateTime.fromGregorian(DateTime gregorianDate) {
    final gYear = gregorianDate.year;
    final gMonth = gregorianDate.month;
    final gDay = gregorianDate.day;

    // Ethiopian calendar starts on September 11/12 in Gregorian calendar
    final ethiopianYear = gYear - 8;

    int ethiopianMonth;
    int ethiopianDay;

    if (gMonth >= 9) {
      // September to December
      if (gMonth == 9) {
        if (gDay >= 11) {
          ethiopianMonth = 1; // Meskerem
          ethiopianDay = gDay - 10;
        } else {
          ethiopianMonth = 13; // Pagume (previous year)
          ethiopianDay = gDay + 5; // Approximate
          // Note: This is simplified - actual Pagume has 5-6 days
        }
      } else {
        ethiopianMonth = gMonth - 8;
        ethiopianDay = gDay;
      }
    } else {
      // January to August
      if (gMonth == 1) {
        if (gDay <= 10) {
          ethiopianMonth = 5; // Tir
          ethiopianDay = gDay + 20; // Approximate
        } else {
          ethiopianMonth = 6; // Yekatit
          ethiopianDay = gDay - 10;
        }
      } else {
        ethiopianMonth = gMonth + 4;
        ethiopianDay = gDay;
      }
    }

    // Adjust for edge cases (simplified)
    if (ethiopianDay > 30) {
      ethiopianDay -= 30;
      ethiopianMonth += 1;
    }

    if (ethiopianMonth > 13) {
      ethiopianMonth = 1;
      // Note: Year adjustment would go here in a complete implementation
    }

    return EthiopianDateTime(
      year: ethiopianYear,
      month: ethiopianMonth,
      day: ethiopianDay,
    );
  }

  // Convert Ethiopian to Gregorian date
  DateTime toGregorian() {
    // Simplified conversion back to Gregorian
    final gregorianYear = year + 8;

    int gregorianMonth;
    int gregorianDay;

    if (month <= 4) {
      gregorianMonth = month + 8;
      gregorianDay = day;
    } else {
      gregorianMonth = month - 4;
      gregorianDay = day;
    }

    // Adjust for edge cases
    if (gregorianMonth > 12) {
      gregorianMonth -= 12;
      // Note: Year adjustment would go here
    }

    return DateTime(gregorianYear, gregorianMonth, gregorianDay);
  }

  @override
  String toString() {
    return 'EthiopianDateTime{year: $year, month: $month, day: $day}';
  }
}

class CalendarUtils {
  static CalendarType get currentCalendar {
    return CalendarType.gregorian; // Default, will be overridden by provider
  }

  static Future<void> setCalendarType(CalendarType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('preferred_calendar', type.index);
  }

  // Date conversion utilities
  static EthiopianDateTime toEthiopian(DateTime gregorianDate) {
    return EthiopianDateTime.fromGregorian(gregorianDate);
  }

  static DateTime toGregorian(EthiopianDateTime ethiopianDate) {
    return ethiopianDate.toGregorian();
  }

  // Format date based on selected calendar
  static String formatDate(
      DateTime date, CalendarType calendarType, BuildContext context) {
    final locale = Localizations.localeOf(context);

    if (calendarType == CalendarType.ethiopian) {
      final ethiopianDate = toEthiopian(date);
      return '${ethiopianDate.day}/${ethiopianDate.month}/${ethiopianDate.year}';
    } else {
      return DateFormat('dd/MM/yyyy', locale.languageCode).format(date);
    }
  }

  static String formatFullDate(
      DateTime date, CalendarType calendarType, BuildContext context) {
    final locale = Localizations.localeOf(context);

    if (calendarType == CalendarType.ethiopian) {
      final ethiopianDate = toEthiopian(date);
      final monthNames = getEthiopianMonthNames(locale.languageCode);
      final weekdayNames = getEthiopianWeekdayNames(locale.languageCode);

      return '${weekdayNames[date.weekday - 1]}, ${ethiopianDate.day} ${monthNames[ethiopianDate.month - 1]} ${ethiopianDate.year}';
    } else {
      return DateFormat('EEEE, MMMM d, y', locale.languageCode).format(date);
    }
  }

  static String formatDateTime(
      DateTime date, CalendarType calendarType, BuildContext context) {
    final locale = Localizations.localeOf(context);
    final timeFormat = DateFormat('HH:mm', locale.languageCode);

    if (calendarType == CalendarType.ethiopian) {
      final ethiopianDate = toEthiopian(date);
      return '${ethiopianDate.day}/${ethiopianDate.month}/${ethiopianDate.year} ${timeFormat.format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm', locale.languageCode).format(date);
    }
  }

  // Get current date in selected calendar
  static String getCurrentDate(
      CalendarType calendarType, BuildContext context) {
    return formatDate(DateTime.now(), calendarType, context);
  }

  static String getCurrentFullDate(
      CalendarType calendarType, BuildContext context) {
    return formatFullDate(DateTime.now(), calendarType, context);
  }

  // Ethiopian calendar names
  static List<String> getEthiopianMonthNames(String languageCode) {
    if (languageCode == 'am') {
      return [
        'መስከረም',
        'ጥቅምት',
        'ኅዳር',
        'ታህሣሥ',
        'ጥር',
        'የካቲት',
        'መጋቢት',
        'ሚያዝያ',
        'ግንቦት',
        'ሰኔ',
        'ሐምሌ',
        'ነሐሴ',
        'ጳጉሜ'
      ];
    } else {
      return [
        'Meskerem',
        'Tikimit',
        'Hidar',
        'Tahsas',
        'Tir',
        'Yekatit',
        'Megabit',
        'Miyazya',
        'Ginbot',
        'Sene',
        'Hamle',
        'Nehase',
        'Pagume'
      ];
    }
  }

  static List<String> getEthiopianWeekdayNames(String languageCode) {
    if (languageCode == 'am') {
      return ['ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'ዓርብ', 'ቅዳሜ', 'እሑድ'];
    } else {
      return [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
    }
  }

  // Date range utilities
  static Map<String, DateTime> getDateRange(
      CalendarType calendarType, String rangeType) {
    final now = DateTime.now();

    switch (rangeType) {
      case 'today':
        return {
          'start': DateTime(now.year, now.month, now.day),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
      case 'week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        return {
          'start': DateTime(start.year, start.month, start.day),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
      case 'month':
        return {
          'start': DateTime(now.year, now.month, 1),
          'end': DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        };
      default:
        return {
          'start': DateTime(now.year, now.month, now.day),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
    }
  }

  // Validation for Ethiopian dates
  static bool isValidEthiopianDate(int year, int month, int day) {
    if (month < 1 || month > 13) return false;
    if (day < 1 || day > 30) return false;
    // Pagume (13th month) has 5-6 days in leap years
    if (month == 13 && day > 6) return false;
    return true;
  }

  // Get display name for calendar type
  static String getCalendarDisplayName(CalendarType type, String languageCode) {
    if (languageCode == 'am') {
      return type.amharicName;
    } else {
      return type.englishName;
    }
  }

  // Check if date is Ethiopian New Year (September 11)
  static bool isEthiopianNewYear(DateTime date) {
    return date.month == 9 && date.day == 11;
  }

  // Get Ethiopian year from Gregorian date
  static int getEthiopianYear(DateTime gregorianDate) {
    final ethDate = toEthiopian(gregorianDate);
    return ethDate.year;
  }
}

// JSON utility for encoding/decoding

// Extension for easy JSON serialization
extension CalendarSettingsJson on CalendarSettings {
  String toJson() => json.encode(toMap());

  static CalendarSettings fromJson(String jsonString) {
    return CalendarSettings.fromMap(json.decode(jsonString));
  }
}
