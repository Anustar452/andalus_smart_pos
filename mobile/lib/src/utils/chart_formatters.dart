// lib/src/utils/chart_formatters.dart
// Utility class for formatting numbers in charts, including currency and percentage formats.
import 'package:intl/intl.dart';

class ChartFormatters {
  static NumberFormat get currencyFormat {
    return NumberFormat.currency(
      symbol: 'ETB ',
      decimalDigits: 2,
    );
  }

  static NumberFormat get compactCurrency {
    return NumberFormat.compactCurrency(
      symbol: 'ETB ',
      decimalDigits: 0,
    );
  }

  static NumberFormat get percentageFormat {
    return NumberFormat.percentPattern();
  }
}
