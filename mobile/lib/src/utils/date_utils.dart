// src/utils/date_utils.dart
// Utility class for date and time formatting, conversions, and calculations,
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:andalus_smart_pos/src/providers/calendar_provider.dart';
import 'package:andalus_smart_pos/src/providers/language_provider.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart'; // Import the actual AppLocalizations
import 'ethiopian_calendar.dart';

class AppDateUtils {
  // Date formats
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _fullDateFormat = DateFormat('EEEE, MMMM d, y');
  static final DateFormat _monthYearFormat = DateFormat('MMMM y');
  static final DateFormat _weekdayFormat = DateFormat('EEEE');
  static final DateFormat _shortDateFormat = DateFormat('MMM d, y');

  // Ethiopian date formats (Amharic)
  static final DateFormat _ethiopianDateFormat =
      DateFormat('dd/MM/yyyy', 'am_ET');
  static final DateFormat _ethiopianDateTimeFormat =
      DateFormat('dd/MM/yyyy HH:mm', 'am_ET');

  // Basic date formatting
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatFullDate(DateTime date) {
    return _fullDateFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatWeekday(DateTime date) {
    return _weekdayFormat.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  // Ethiopian date formatting
  static String formatEthiopianDate(DateTime date) {
    return _ethiopianDateFormat.format(date);
  }

  static String formatEthiopianDateTime(DateTime date) {
    return _ethiopianDateTimeFormat.format(date);
  }

  // Get current date in selected calendar
  static String getCurrentDate(BuildContext context, WidgetRef ref) {
    final calendarSettings = ref.read(calendarProvider);
    final now = DateTime.now();

    if (calendarSettings.calendarType == CalendarType.ethiopian) {
      final ethDate = EthiopianCalendar.gregorianToEthiopian(now);
      return '${ethDate.day}/${ethDate.month}/${ethDate.year}';
    } else {
      return formatDate(now);
    }
  }

  static String getCurrentFullDate(BuildContext context, WidgetRef ref) {
    final calendarSettings = ref.read(calendarProvider);
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);

    if (calendarSettings.calendarType == CalendarType.ethiopian) {
      final ethDate = EthiopianCalendar.gregorianToEthiopian(now);
      return EthiopianCalendar.formatDate(ethDate, locale.languageCode);
    } else {
      return formatFullDate(now);
    }
  }

  static String getCurrentDateDisplay(WidgetRef ref) {
    final now = DateTime.now();
    final calendarSettings = ref.read(calendarProvider);
    final locale = ref.read(languageProvider);

    if (calendarSettings.calendarType == CalendarType.ethiopian) {
      final ethDate = EthiopianCalendar.gregorianToEthiopian(now);
      return '${ethDate.day}/${ethDate.month}/${ethDate.year}';
    } else {
      return formatDate(now);
    }
  }

  static String formatLiveTime(DateTime time, WidgetRef ref) {
    return DateFormat('HH:mm:ss').format(time);
  }

  static String formatDateBasedOnCalendar(
      DateTime date, CalendarType calendarType, BuildContext context) {
    if (calendarType == CalendarType.ethiopian) {
      final ethDate = EthiopianCalendar.gregorianToEthiopian(date);
      return '${ethDate.day}/${ethDate.month}/${ethDate.year}';
    } else {
      return formatDate(date);
    }
  }

  static String formatFullDateBasedOnCalendar(
      DateTime date, CalendarType calendarType, BuildContext context) {
    if (calendarType == CalendarType.ethiopian) {
      final ethDate = EthiopianCalendar.gregorianToEthiopian(date);
      final locale = Localizations.localeOf(context);
      return EthiopianCalendar.formatDate(ethDate, locale.languageCode);
    } else {
      return formatFullDate(date);
    }
  }

  // Get live date time with proper ref
  static String getLiveDateTime(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final calendarSettings = ref.read(calendarProvider);
    final timeFormat = DateFormat('HH:mm:ss');

    if (calendarSettings.calendarType == CalendarType.ethiopian) {
      final ethDate = EthiopianCalendar.gregorianToEthiopian(now);
      return '${ethDate.day}/${ethDate.month}/${ethDate.year} ${timeFormat.format(now)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(now);
    }
  }

  // Relative time formatting
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(date);
    }
  }

  // Business date utilities
  static DateTime get startOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime get endOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  static DateTime get startOfWeek {
    final now = DateTime.now();
    final weekday = now.weekday;
    return DateTime(now.year, now.month, now.day - weekday + 1);
  }

  static DateTime get endOfWeek {
    final now = DateTime.now();
    final weekday = now.weekday;
    return DateTime(
        now.year, now.month, now.day + (7 - weekday), 23, 59, 59, 999);
  }

  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
  }

  static DateTime get startOfYear {
    final now = DateTime.now();
    return DateTime(now.year, 1, 1);
  }

  static DateTime get endOfYear {
    final now = DateTime.now();
    return DateTime(now.year, 12, 31, 23, 59, 59, 999);
  }

  // Date range utilities
  static List<DateTime> getLast7Days() {
    final List<DateTime> days = [];
    for (int i = 6; i >= 0; i--) {
      days.add(DateTime.now().subtract(Duration(days: i)));
    }
    return days;
  }

  static List<DateTime> getLast30Days() {
    final List<DateTime> days = [];
    for (int i = 29; i >= 0; i--) {
      days.add(DateTime.now().subtract(Duration(days: i)));
    }
    return days;
  }

  static List<DateTime> getLast90Days() {
    final List<DateTime> days = [];
    for (int i = 89; i >= 0; i--) {
      days.add(DateTime.now().subtract(Duration(days: i)));
    }
    return days;
  }

  static List<DateTime> getLast365Days() {
    final List<DateTime> days = [];
    for (int i = 364; i >= 0; i--) {
      days.add(DateTime.now().subtract(Duration(days: i)));
    }
    return days;
  }

  // Validation utilities
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day - now.weekday + 1);
    final endOfWeek =
        DateTime(now.year, now.month, now.day + (7 - now.weekday), 23, 59, 59);
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  // Age calculation
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Due date calculations for credit management
  static DateTime calculateDueDate(DateTime fromDate, int days) {
    return fromDate.add(Duration(days: days));
  }

  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  static int daysUntilDue(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inDays;
  }

  static int daysOverdue(DateTime dueDate) {
    final now = DateTime.now();
    final difference = now.difference(dueDate);
    return difference.inDays;
  }

  static String formatDueDate(DateTime dueDate) {
    if (isOverdue(dueDate)) {
      final int overdueDays = daysOverdue(dueDate);

      return '$overdueDays days overdue';
    } else {
      final daysUntil = daysUntilDue(dueDate);
      return 'Due in $daysUntil days';
    }
  }

  // Sales period formatting
  static String formatSalesPeriod(DateTime start, DateTime end) {
    if (isToday(start) && isToday(end)) {
      return 'Today';
    } else if (isThisWeek(start) && isThisWeek(end)) {
      return 'This Week';
    } else if (isThisMonth(start) && isThisMonth(end)) {
      return 'This Month';
    } else {
      return '${formatDate(start)} - ${formatDate(end)}';
    }
  }

  // Ethiopian calendar utilities
  static EthiopianDate toEthiopianDate(DateTime gregorianDate) {
    return EthiopianCalendar.gregorianToEthiopian(gregorianDate);
  }

  static DateTime toGregorianDate(EthiopianDate ethiopianDate) {
    return EthiopianCalendar.ethiopianToGregorian(ethiopianDate);
  }

  // Time utility for business hours
  static bool isBusinessHours(DateTime time) {
    final hour = time.hour;
    return hour >= 8 && hour <= 20; // 8 AM to 8 PM
  }

  static String formatBusinessHours(DateTime time) {
    if (isBusinessHours(time)) {
      return 'Open';
    } else {
      return 'Closed';
    }
  }

  // Duration formatting
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  static String formatDurationShort(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Date comparison for sorting
  static int compareDates(DateTime a, DateTime b) {
    return b.compareTo(a); // Descending order (newest first)
  }

  static int compareDatesAscending(DateTime a, DateTime b) {
    return a.compareTo(b); // Ascending order (oldest first)
  }

  // Get readable time ago string
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Quick date presets for reports and analytics
  static Map<String, DateTimeRange> getDatePresets() {
    final now = DateTime.now();
    return {
      'today': DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      ),
      'yesterday': DateTimeRange(
        start: DateTime(now.year, now.month, now.day - 1),
        end: DateTime(now.year, now.month, now.day - 1, 23, 59, 59),
      ),
      'this_week': DateTimeRange(
        start: DateTime(now.year, now.month, now.day - now.weekday + 1),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      ),
      'last_week': DateTimeRange(
        start: DateTime(now.year, now.month, now.day - now.weekday - 6),
        end: DateTime(now.year, now.month, now.day - now.weekday, 23, 59, 59),
      ),
      'this_month': DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      ),
      'last_month': DateTimeRange(
        start: DateTime(now.year, now.month - 1, 1),
        end: DateTime(now.year, now.month, 0, 23, 59, 59),
      ),
      'last_3_months': DateTimeRange(
        start: DateTime(now.year, now.month - 3, 1),
        end: DateTime(now.year, now.month, 0, 23, 59, 59),
      ),
      'last_6_months': DateTimeRange(
        start: DateTime(now.year, now.month - 6, 1),
        end: DateTime(now.year, now.month, 0, 23, 59, 59),
      ),
      'this_year': DateTimeRange(
        start: DateTime(now.year, 1, 1),
        end: DateTime(now.year, 12, 31, 23, 59, 59),
      ),
      'last_year': DateTimeRange(
        start: DateTime(now.year - 1, 1, 1),
        end: DateTime(now.year - 1, 12, 31, 23, 59, 59),
      ),
    };
  }

  // Get display name for date presets
  static String getDatePresetDisplayName(
      String presetKey, BuildContext context) {
    final localizations = AppLocalizations.of(context);

    switch (presetKey) {
      case 'today':
        return localizations.today;
      case 'yesterday':
        return localizations.translate('yesterday');
      case 'this_week':
        return localizations.translate('thisWeek');
      case 'last_week':
        return localizations.translate('lastWeek');
      case 'this_month':
        return localizations.thisMonth;
      case 'last_month':
        return localizations.translate('lastMonth');
      case 'last_3_months':
        return localizations.translate('last3Months');
      case 'last_6_months':
        return localizations.translate('last6Months');
      case 'this_year':
        return localizations.translate('thisYear');
      case 'last_year':
        return localizations.translate('lastYear');
      default:
        return presetKey;
    }
  }

  // Date range calculations
  static int getDaysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  static int getMonthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + to.month - from.month;
  }

  static int getYearsBetween(DateTime from, DateTime to) {
    return to.year - from.year;
  }

  // Ethiopian calendar specific utilities
  static bool isEthiopianLeapYear(int ethYear) {
    return EthiopianCalendar.isEthiopianLeapYear(ethYear);
  }

  static String getEthiopianMonthName(int month, String languageCode) {
    final monthNames = EthiopianCalendar.getMonthNames(languageCode);
    return monthNames[month - 1];
  }

  static String getEthiopianWeekdayName(int weekday, String languageCode) {
    final weekdayNames = EthiopianCalendar.getWeekdayNames(languageCode);
    return weekdayNames[weekday - 1];
  }

  // Date validation
  static bool isValidDate(int year, int month, int day) {
    try {
      DateTime(year, month, day);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isValidEthiopianDate(int year, int month, int day) {
    return EthiopianCalendar.isValidEthiopianDate(year, month, day);
  }

  // Date manipulation
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  static DateTime addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }

  static DateTime subtractMonths(DateTime date, int months) {
    return DateTime(date.year, date.month - months, date.day);
  }

  static DateTime addYears(DateTime date, int years) {
    return DateTime(date.year + years, date.month, date.day);
  }

  static DateTime subtractYears(DateTime date, int years) {
    return DateTime(date.year - years, date.month, date.day);
  }

  // First and last day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Week number calculations
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(firstDayOfYear).inDays;
    return ((days + firstDayOfYear.weekday - 1) / 7).floor() + 1;
  }

  // Quarter calculations
  static int getQuarter(DateTime date) {
    return ((date.month - 1) / 3).floor() + 1;
  }

  static DateTime getFirstDayOfQuarter(DateTime date) {
    final quarter = getQuarter(date);
    final month = (quarter - 1) * 3 + 1;
    return DateTime(date.year, month, 1);
  }

  static DateTime getLastDayOfQuarter(DateTime date) {
    final quarter = getQuarter(date);
    final month = quarter * 3;
    return DateTime(date.year, month + 1, 0);
  }

  // Ethiopian calendar quarter calculations
  static int getEthiopianQuarter(EthiopianDate ethDate) {
    return ((ethDate.month - 1) / 3).floor() + 1;
  }

  static EthiopianDate getFirstDayOfEthiopianQuarter(EthiopianDate ethDate) {
    final quarter = getEthiopianQuarter(ethDate);
    final month = (quarter - 1) * 3 + 1;
    return EthiopianDate(year: ethDate.year, month: month, day: 1);
  }

  static EthiopianDate getLastDayOfEthiopianQuarter(EthiopianDate ethDate) {
    final quarter = getEthiopianQuarter(ethDate);
    final month = quarter * 3;
    return EthiopianDate(year: ethDate.year, month: month, day: 30);
  }

  // Date range string for display
  static String formatDateRange(
      DateTimeRange range, BuildContext context, WidgetRef ref) {
    final calendarSettings = ref.read(calendarProvider);

    final start = formatDateBasedOnCalendar(
        range.start, calendarSettings.calendarType, context);
    final end = formatDateBasedOnCalendar(
        range.end, calendarSettings.calendarType, context);

    return '$start - $end';
  }

  // Check if date is within range
  static bool isDateInRange(DateTime date, DateTimeRange range) {
    return (date.isAfter(range.start) || date.isAtSameMomentAs(range.start)) &&
        (date.isBefore(range.end) || date.isAtSameMomentAs(range.end));
  }

  // Get current Ethiopian date
  static EthiopianDate getCurrentEthiopianDate() {
    return EthiopianCalendar.getCurrentEthiopianDate();
  }

  // Format Ethiopian date for display
  static String formatEthiopianDateForDisplay(
      EthiopianDate ethDate, String languageCode) {
    return ethDate.toFormattedString(languageCode);
  }

  // Get Ethiopian date components
  static Map<String, dynamic> getEthiopianDateComponents(
      DateTime gregorianDate) {
    final ethDate = EthiopianCalendar.gregorianToEthiopian(gregorianDate);
    return {
      'year': ethDate.year,
      'month': ethDate.month,
      'day': ethDate.day,
      'month_name_en': EthiopianCalendar.getMonthNames('en')[ethDate.month - 1],
      'month_name_am': EthiopianCalendar.getMonthNames('am')[ethDate.month - 1],
      'weekday_en':
          EthiopianCalendar.getWeekdayNames('en')[gregorianDate.weekday - 1],
      'weekday_am':
          EthiopianCalendar.getWeekdayNames('am')[gregorianDate.weekday - 1],
    };
  }
}
