import 'package:andalus_smart_pos/src/data/models/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:andalus_smart_pos/src/data/models/settings.dart";

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    try {
      final repository = _getRepository();
      return await repository.getSettings();
    } catch (e) {
      print('Error building settings: $e');
      // Return default settings as fallback
      return _getDefaultSettings();
    }
  }

  SettingsRepository _getRepository() {
    return SettingsRepository(); // Your settings repository
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

  Future<void> updateSettings(AppSettings newSettings) async {
    state = const AsyncValue.loading();
    try {
      final repository = _getRepository();
      await repository.saveSettings(newSettings);
      state = AsyncValue.data(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> resetToDefaults() async {
    final defaultSettings = _getDefaultSettings();
    await updateSettings(defaultSettings);
  }
}

// Simple Settings Repository for SharedPreferences
class SettingsRepository {
  static const String _settingsKey = 'app_settings';

  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // In a real app, you'd parse JSON here
    // For now, return default settings
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

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    // In a real app, you'd convert to JSON here
    await prefs.setString(_settingsKey, 'settings_saved');
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate save
  }
}
