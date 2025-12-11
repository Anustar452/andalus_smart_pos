// utils/ethiopian_calendar.dart
// Utility class for Ethiopian calendar conversions and date handling.
// Provides functions to convert between Gregorian and Ethiopian dates,
// check leap years, and format Ethiopian dates.

class EthiopianCalendar {
  // Accurate Ethiopian calendar conversion constants
  static const int ETHIOPIAN_YEAR_OFFSET = 8;
  static const int JDN_OFFSET = 1723856;
  static const int ETHIOPIAN_EPOCH = 1724221; // JD of 1 Mäskäräm 1 ETH

  static const List<int> MONTH_DAYS = [
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    5
  ];
  static const List<String> MONTH_NAMES_EN = [
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
  static const List<String> MONTH_NAMES_AM = [
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
    'ነሃሴ',
    'ጳጉሜ'
  ];
  static const List<String> WEEKDAY_NAMES_EN = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  static const List<String> WEEKDAY_NAMES_AM = [
    'ሰኞ',
    'ማክሰኞ',
    'ረቡዕ',
    'ሐሙስ',
    'ዓርብ',
    'ቅዳሜ',
    'እሑድ'
  ];

  // Convert Gregorian to Julian Day Number
  static int _toJulianDay(DateTime gregorianDate) {
    int year = gregorianDate.year;
    int month = gregorianDate.month;
    int day = gregorianDate.day;

    int a = (14 - month) ~/ 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;

    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  // Convert Julian Day Number to Gregorian
  static DateTime _fromJulianDay(int jd) {
    int a = jd + 32044;
    int b = (4 * a + 3) ~/ 146097;
    int c = a - (146097 * b) ~/ 4;
    int d = (4 * c + 3) ~/ 1461;
    int e = c - (1461 * d) ~/ 4;
    int m = (5 * e + 2) ~/ 153;

    int day = e - (153 * m + 2) ~/ 5 + 1;
    int month = m + 3 - 12 * (m ~/ 10);
    int year = 100 * b + d - 4800 + (m ~/ 10);

    return DateTime(year, month, day);
  }

  // Convert Gregorian to Ethiopian date (ACCURATE)
  static EthiopianDate gregorianToEthiopian(DateTime gregorianDate) {
    int jd = _toJulianDay(gregorianDate);

    // Calculate Ethiopian date from Julian Day
    int n = jd - ETHIOPIAN_EPOCH;
    int year = 4 * n ~/ 1461;
    int remainder = n - 1461 * year ~/ 4;
    int month = remainder ~/ 30 + 1;
    int day = remainder % 30 + 1;

    return EthiopianDate(year: year + 1, month: month, day: day);
  }

  // Convert Ethiopian to Gregorian date (ACCURATE)
  static DateTime ethiopianToGregorian(EthiopianDate ethDate) {
    int jd = ETHIOPIAN_EPOCH +
        365 * (ethDate.year - 1) +
        (ethDate.year - 1) ~/ 4 +
        30 * (ethDate.month - 1) +
        (ethDate.day - 1);

    return _fromJulianDay(jd);
  }

  // Check if Ethiopian year is leap year
  static bool isEthiopianLeapYear(int ethYear) {
    return (ethYear % 4) == 3;
  }

  // Get month names
  static List<String> getMonthNames(String languageCode) {
    return languageCode == 'am' ? MONTH_NAMES_AM : MONTH_NAMES_EN;
  }

  // Get weekday names
  static List<String> getWeekdayNames(String languageCode) {
    return languageCode == 'am' ? WEEKDAY_NAMES_AM : WEEKDAY_NAMES_EN;
  }

  // Format Ethiopian date
  static String formatDate(EthiopianDate ethDate, String languageCode) {
    final monthNames = getMonthNames(languageCode);
    final weekdayNames = getWeekdayNames(languageCode);

    final gregorianDate = ethiopianToGregorian(ethDate);
    final weekday = gregorianDate.weekday - 1;

    return '${weekdayNames[weekday]}, ${ethDate.day} ${monthNames[ethDate.month - 1]} ${ethDate.year}';
  }

  // Get current Ethiopian date
  static EthiopianDate getCurrentEthiopianDate() {
    return gregorianToEthiopian(DateTime.now());
  }

  // Validate Ethiopian date
  static bool isValidEthiopianDate(int year, int month, int day) {
    if (month < 1 || month > 13) return false;
    if (day < 1) return false;

    if (month == 13) {
      // Pagume has 5-6 days
      int maxDays = isEthiopianLeapYear(year) ? 6 : 5;
      return day <= maxDays;
    } else {
      return day <= 30;
    }
  }
}

class EthiopianDate {
  final int year;
  final int month;
  final int day;

  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  String toString() {
    return '$day/$month/$year';
  }

  String toFormattedString(String languageCode) {
    final monthNames = EthiopianCalendar.getMonthNames(languageCode);
    return '${day} ${monthNames[month - 1]} ${year}';
  }
}
