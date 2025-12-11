// lib/src/utils/validators.dart
// Utility class for validating various input fields such as product details, customer information, and sales data.
import 'package:intl/intl.dart';

class Validators {
  // === PRODUCT VALIDATION ===
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required';
    }
    if (value.length < 2) {
      return 'Product name must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Product name cannot exceed 100 characters';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    if (price > 10000000) {
      return 'Price cannot exceed 10,000,000';
    }
    return null;
  }

  static String? validateBarcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Barcode is required';
    }

    value = value.trim();

    // Check length
    if (value.length < 8 || value.length > 14) {
      return 'Barcode must be 8-14 digits';
    }

    // Check if all digits
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Barcode must contain only numbers';
    }

    // Validate check digit for EAN-13
    if (value.length == 13) {
      if (!_validateEAN13CheckDigit(value)) {
        return 'Invalid EAN-13 barcode (check digit mismatch)';
      }
    }

    return null;
  }

  static bool _validateEAN13CheckDigit(String code) {
    if (code.length != 13) return false;

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(code[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }

    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(code[12]);
  }

  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stock quantity is required';
    }

    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Please enter a valid number';
    }
    if (stock < 0) {
      return 'Stock cannot be negative';
    }
    if (stock > 1000000) {
      return 'Stock cannot exceed 1,000,000';
    }
    return null;
  }

  // === CUSTOMER VALIDATION ===
  static String? validatePhoneNumber(String? value, {bool isEthiopian = true}) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Clean the number
    String cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (isEthiopian) {
      // Ethiopian phone validation
      if (!cleaned.startsWith('+251') &&
          !cleaned.startsWith('251') &&
          !cleaned.startsWith('0')) {
        return 'Please enter a valid Ethiopian phone number';
      }

      // Standardize to +251 format
      if (cleaned.startsWith('0')) {
        cleaned = '+251${cleaned.substring(1)}';
      } else if (cleaned.startsWith('251')) {
        cleaned = '+$cleaned';
      }

      // Check length
      if (cleaned.length != 13) {
        // +251XXXXXXXXX
        return 'Phone number must be 9 digits after +251';
      }
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validateTIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'TIN number is required';
    }

    // Ethiopian TIN validation (basic)
    if (!RegExp(r'^\d{9,10}$').hasMatch(value)) {
      return 'TIN must be 9 or 10 digits';
    }

    return null;
  }

  // === SALE VALIDATION ===
  static String? validatePaymentAmount(String? value, double maxAmount) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > maxAmount) {
      return 'Amount cannot exceed ${NumberFormat.currency(symbol: 'ETB ').format(maxAmount)}';
    }
    return null;
  }

  static String? validateCreditLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit limit is required';
    }

    final limit = double.tryParse(value);
    if (limit == null) {
      return 'Please enter a valid number';
    }
    if (limit < 0) {
      return 'Credit limit cannot be negative';
    }
    if (limit > 1000000) {
      return 'Credit limit cannot exceed 1,000,000';
    }
    return null;
  }

  // === GENERAL VALIDATION ===
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateLength(
      String? value, int min, int max, String fieldName) {
    if (value == null) return null;

    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    if (value.length > max) {
      return '$fieldName cannot exceed $max characters';
    }
    return null;
  }

  static String? validateNumberRange(
      String? value, double min, double max, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < min) {
      return '$fieldName must be at least $min';
    }
    if (number > max) {
      return '$fieldName cannot exceed $max';
    }
    return null;
  }

  // === DATE VALIDATION ===
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  static bool isValidDate(DateTime? date) {
    if (date == null) return false;
    return date
        .isBefore(DateTime.now().add(const Duration(days: 1))); // Not in future
  }

  // === PASSWORD VALIDATION ===
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Optional: Add complexity requirements
    // if (!RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).+$').hasMatch(value)) {
    //   return 'Password must contain uppercase and special characters';
    // }

    return null;
  }

  static String? validateConfirmPassword(
      String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // === BATCH VALIDATION ===
  static Map<String, String?> validateProductData(Map<String, dynamic> data) {
    return {
      'name': validateProductName(data['name']),
      'price': validatePrice(data['price']?.toString()),
      'barcode': validateBarcode(data['barcode']),
      'stock': validateStock(data['stock']?.toString()),
      'categoryId': validateRequired(data['categoryId'], 'Category'),
    };
  }

  static Map<String, String?> validateCustomerData(Map<String, dynamic> data) {
    return {
      'name': validateRequired(data['name'], 'Name'),
      'phone': validatePhoneNumber(data['phone']),
      'email': validateEmail(data['email']),
      'creditLimit': validateCreditLimit(data['creditLimit']?.toString()),
    };
  }

  // === UTILITY METHODS ===
  static bool hasValidationErrors(Map<String, String?> errors) {
    return errors.values.any((error) => error != null);
  }

  static String getFirstError(Map<String, String?> errors) {
    final error =
        errors.values.firstWhere((error) => error != null, orElse: () => null);
    return error ?? '';
  }

  static String formatValidationErrors(Map<String, String?> errors) {
    final errorMessages =
        errors.values.where((error) => error != null).toList();
    return errorMessages.join('\n');
  }
}
