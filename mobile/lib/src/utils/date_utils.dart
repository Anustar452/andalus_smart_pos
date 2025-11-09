import 'package:intl/intl.dart';

class AppDateUtils {
  // Date formats
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _fullDateFormat = DateFormat('EEEE, MMMM d, y');
  static final DateFormat _monthYearFormat = DateFormat('MMMM y');
  static final DateFormat _weekdayFormat = DateFormat('EEEE');

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

  // Ethiopian date formatting
  static String formatEthiopianDate(DateTime date) {
    return _ethiopianDateFormat.format(date);
  }

  static String formatEthiopianDateTime(DateTime date) {
    return _ethiopianDateTimeFormat.format(date);
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

  // Validation utilities
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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

  static String formatDueDate(DateTime dueDate) {
    if (isOverdue(dueDate)) {
      final daysOverdue = DateTime.now().difference(dueDate).inDays;
      return '$daysOverdue days overdue';
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

  // Ethiopian calendar utilities (basic implementation)
  static Map<String, dynamic> toEthiopianDate(DateTime gregorianDate) {
    // Basic conversion - in a real app, you'd use a proper Ethiopian calendar library
    final ethiopianYear = gregorianDate.year - 8;
    final ethiopianMonth = gregorianDate.month;
    final ethiopianDay = gregorianDate.day;

    return {
      'year': ethiopianYear,
      'month': ethiopianMonth,
      'day': ethiopianDay,
      'formatted': '${ethiopianDay}/${ethiopianMonth}/${ethiopianYear}'
    };
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
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  // Date comparison for sorting
  static int compareDates(DateTime a, DateTime b) {
    return b.compareTo(a); // Descending order (newest first)
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
}
