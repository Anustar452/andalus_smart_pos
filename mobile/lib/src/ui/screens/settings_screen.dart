import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/settings.dart';
import 'package:andalus_smart_pos/src/providers/settings_provider.dart';
import 'package:andalus_smart_pos/src/providers/theme_provider.dart';
import 'package:andalus_smart_pos/src/providers/language_provider.dart';
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';
import 'package:andalus_smart_pos/src/widgets/common/loading_shimmer.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late AppSettings _currentSettings;
  bool _hasChanges = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    final settingsAsync = ref.read(settingsProvider);

    settingsAsync.when(
      data: (settings) {
        if (mounted) {
          setState(() {
            _currentSettings = settings;
            _isInitialized = true;
          });
        }
      },
      loading: () {
        if (mounted) {
          setState(() {
            // Use default settings while loading
            _currentSettings = _getDefaultSettings();
            _isInitialized = true;
          });
        }
      },
      error: (error, stack) {
        if (mounted) {
          setState(() {
            // Use default settings on error
            _currentSettings = _getDefaultSettings();
            _isInitialized = true;
          });
        }
        // You might want to show an error snackbar here

        // print('Error loading settings: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
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

  void _updateSetting<T>(T Function(AppSettings) update) {
    if (!_isInitialized) return;

    setState(() {
      _currentSettings = update(_currentSettings) as AppSettings;
      _hasChanges = true;
    });
  }

  Future<void> _saveSettings() async {
    if (!_isInitialized) return;
    if (_formKey.currentState!.validate()) {
      try {
        final notifier = ref.read(settingsProvider.notifier);
        await notifier.updateSettings(_currentSettings);

        setState(() => _hasChanges = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving settings: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performReset();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _performReset() async {
    try {
      final notifier = ref.read(settingsProvider.notifier);
      await notifier.resetToDefaults();

      // Reload settings
      _initializeSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider); // This is now ThemeMode
    final locale = ref.watch(languageProvider);

    if (!_isInitialized) {
      return _buildLoadingState();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveSettings,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Appearance Section - now uses ThemeMode directly
            _buildAppearanceSection(themeMode, locale),
            const SizedBox(height: 16),

            // Business Information
            _buildBusinessSettings(),
            const SizedBox(height: 16),
            // POS Settings
            _buildPosSettings(),
            const SizedBox(height: 16),
            // Credit Settings
            _buildCreditSettings(),
            const SizedBox(height: 16),
            // Sync Settings
            _buildSyncSettings(),
            const SizedBox(height: 16),
            // Advanced Settings
            _buildAdvancedSettings(),
            const SizedBox(height: 24),
            // Reset Section
            _buildResetSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF10B981)),
            SizedBox(height: 16),
            Text('Loading settings...'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(ThemeMode themeMode, Locale locale) {
    final localizations = AppLocalizations.of(context);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                localizations.appearanceLanguage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Theme Mode
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(localizations.themeMode),
            subtitle: Text(_getThemeModeText(themeMode, localizations)),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (newMode) {
                if (newMode != null) {
                  ref.read(themeProvider.notifier).setTheme(newMode);
                }
              },
              items: ThemeMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(_getThemeModeText(mode, localizations)),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizations.language),
            subtitle: Text(_getLanguageText(locale, localizations)),
            trailing: DropdownButton<Locale>(
              value: locale,
              onChanged: (newLocale) {
                if (newLocale != null) {
                  ref
                      .read(languageProvider.notifier)
                      .setLanguage(newLocale.languageCode);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('am'),
                  child: Text('አማርኛ'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode, AppLocalizations localizations) {
    switch (mode) {
      case ThemeMode.light:
        return localizations.light;
      case ThemeMode.dark:
        return localizations.dark;
      case ThemeMode.system:
        return localizations.systemDefault;
    }
  }

  String _getLanguageText(Locale locale, AppLocalizations localizations) {
    return locale.languageCode == 'en'
        ? localizations.english
        : localizations.amharic;
  }

  Widget _buildBusinessSettings() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                'Business Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Shop Name (English)',
            value: _currentSettings.shopName,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(shopName: value)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Shop Name (Amharic)',
            value: _currentSettings.shopNameAm,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(shopNameAm: value)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Address',
            value: _currentSettings.address,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(address: value)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Phone',
            value: _currentSettings.phone,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(phone: value)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'TIN Number',
            value: _currentSettings.tinNumber,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(tinNumber: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildPosSettings() {
    return CustomCard(
      margin: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.point_of_sale, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                'POS Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitch(
            title: 'Auto Print Receipts',
            value: _currentSettings.autoPrintReceipts,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(autoPrintReceipts: value)),
          ),
          _buildSwitch(
            title: 'Enable Customer Selection',
            value: _currentSettings.enableCustomerSelection,
            onChanged: (value) => _updateSetting(
                (s) => s.copyWith(enableCustomerSelection: value)),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Default Payment Method',
            value: _currentSettings.defaultPaymentMethod,
            items: const ['cash', 'telebirr', 'card', 'bank_transfer'],
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(defaultPaymentMethod: value!)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditSettings() {
    return CustomCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                'Credit Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitch(
            title: 'Enable Credit System',
            value: _currentSettings.enableCreditSystem,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(enableCreditSystem: value)),
          ),
          if (_currentSettings.enableCreditSystem) ...[
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Default Credit Limit (ETB)',
              value: _currentSettings.defaultCreditLimit.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final limit = double.tryParse(value) ?? 1000.0;
                _updateSetting((s) => s.copyWith(defaultCreditLimit: limit));
              },
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'Default Payment Terms (Days)',
              value: _currentSettings.defaultPaymentTerms,
              items: const ['7', '15', '30', '45', '60'],
              onChanged: (value) => _updateSetting(
                  (s) => s.copyWith(defaultPaymentTerms: value!)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncSettings() {
    return CustomCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                'Sync Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitch(
            title: 'Enable Data Sync',
            value: _currentSettings.enableSync,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(enableSync: value)),
          ),
          if (_currentSettings.enableSync) ...[
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'Sync Interval (minutes)',
              value: _currentSettings.syncInterval.toString(),
              items: const ['1', '5', '15', '30', '60'],
              onChanged: (value) => _updateSetting(
                  (s) => s.copyWith(syncInterval: int.parse(value!))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return CustomCard(
      margin: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                'Advanced Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitch(
            title: 'Enable Tax',
            value: _currentSettings.enableTax,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(enableTax: value)),
          ),
          if (_currentSettings.enableTax) ...[
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Tax Rate (%)',
              value: (_currentSettings.taxRate * 100).toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final rate = double.tryParse(value) ?? 15.0;
                _updateSetting((s) => s.copyWith(taxRate: rate / 100));
              },
            ),
          ],
          _buildSwitch(
            title: 'Enable Discounts',
            value: _currentSettings.enableDiscounts,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(enableDiscounts: value)),
          ),
          _buildSwitch(
            title: 'Low Stock Notifications',
            value: _currentSettings.lowStockNotifications,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(lowStockNotifications: value)),
          ),
          if (_currentSettings.lowStockNotifications) ...[
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Low Stock Threshold',
              value: _currentSettings.lowStockThreshold.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final threshold = int.tryParse(value) ?? 10;
                _updateSetting((s) => s.copyWith(lowStockThreshold: threshold));
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResetSection() {
    return CustomCard(
      margin: EdgeInsets.zero,
      backgroundColor: Colors.red.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade600),
              const SizedBox(width: 12),
              Text(
                'Danger Zone',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Reset all settings to their default values. This action cannot be undone.',
            style: TextStyle(color: Colors.red.shade600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _resetToDefaults,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Reset to Default Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  Widget _buildSwitch({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
