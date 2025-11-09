// src/data/repositories/settings_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsRepository {
  static const String _settingsKey =
      'app_settings_v2'; // Change key to force refresh

  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson != null) {
      try {
        // In a real app, you'd parse JSON properly
        // For now, return from map with default values for new fields
        final Map<String, dynamic> settingsMap = {
          'shopName': 'Andalus Smart POS',
          'shopNameAm': 'አንዳሉስ ማርቲን ፖስ',
          'address': 'Addis Ababa, Ethiopia',
          'phone': '+251 911 234 567',
          'tinNumber': 'TIN-123456789',
          'currency': 'ETB',
          'enableTax': false,
          'taxRate': 0.15,
          'enableDiscounts': true,
          'autoPrintReceipts': false,
          'defaultPaymentMethod': 'cash',
          'enableSync': true,
          'syncInterval': 5,
          'enableCreditSystem': true,
          'defaultCreditLimit': 1000.0,
          'defaultPaymentTerms': '30',
          'enableCustomerSelection': true,
          'lowStockNotifications': true,
          'lowStockThreshold': 10,
        };
        return AppSettings.fromMap(settingsMap);
      } catch (e) {
        print('Error parsing settings: $e');
        return _getDefaultSettings();
      }
    }

    return _getDefaultSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    // In a real app, you'd convert to JSON properly
    await prefs.setString(_settingsKey, 'settings_saved_v2');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  AppSettings _getDefaultSettings() {
    return AppSettings(
      shopName: 'Andalus Smart POS',
      shopNameAm: 'አንዳሉስ ማርቲን ፖስ',
      address: 'Addis Ababa, Ethiopia',
      phone: '+251 911 234 567',
      tinNumber: 'TIN-123456789',
      currency: 'ETB',
      enableTax: false,
      taxRate: 0.15,
      enableDiscounts: true,
      autoPrintReceipts: false,
      defaultPaymentMethod: 'cash',
      enableSync: true,
      syncInterval: 5,
      enableCreditSystem: true,
      defaultCreditLimit: 1000.0,
      defaultPaymentTerms: '30',
      enableCustomerSelection: true,
      lowStockNotifications: true,
      lowStockThreshold: 10,
    );
  }

  Future<Map<String, String>> getShopInfo() async {
    final settings = await getSettings();
    return {
      'name': settings.shopName,
      'nameAm': settings.shopNameAm,
      'address': settings.address,
      'phone': settings.phone,
      'tinNumber': settings.tinNumber,
    };
  }
}
