// lib/src/utils/formatters.dart
import 'package:intl/intl.dart';

class AppFormatters {
  // Currency formatting for Ethiopian Birr
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'ETB ',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrency = NumberFormat.compactCurrency(
    symbol: 'ETB ',
    decimalDigits: 0,
  );

  // Number formatting
  static final NumberFormat _numberFormat = NumberFormat('#,##0');
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.00');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCompactCurrency(double amount) {
    return _compactCurrency.format(amount);
  }

  static String formatNumber(int number) {
    return _numberFormat.format(number);
  }

  static String formatDecimal(double number) {
    return _decimalFormat.format(number);
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  // Phone number formatting for Ethiopia
  static String formatPhoneNumber(String phone) {
    if (phone.startsWith('+251')) {
      return phone.replaceFirstMapped(RegExp(r'(\+251)(\d{2})(\d{3})(\d{4})'),
          (match) => '${match[1]} ${match[2]} ${match[3]} ${match[4]}');
    } else if (phone.startsWith('251')) {
      return phone.replaceFirstMapped(RegExp(r'(251)(\d{2})(\d{3})(\d{4})'),
          (match) => '+${match[1]} ${match[2]} ${match[3]} ${match[4]}');
    } else if (phone.startsWith('0')) {
      return phone.replaceFirstMapped(RegExp(r'(0)(\d{2})(\d{3})(\d{4})'),
          (match) => '+251 ${match[2]} ${match[3]} ${match[4]}');
    }
    return phone;
  }

  // TIN number formatting
  static String formatTIN(String tin) {
    if (tin.length == 10) {
      return '${tin.substring(0, 3)}-${tin.substring(3, 6)}-${tin.substring(6)}';
    }
    return tin;
  }

  // Text capitalization
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
}
