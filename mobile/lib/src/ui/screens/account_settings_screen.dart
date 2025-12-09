import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/settings.dart';
import 'package:andalus_smart_pos/src/providers/settings_provider.dart';
import 'package:andalus_smart_pos/src/providers/theme_provider.dart';
import 'package:andalus_smart_pos/src/providers/language_provider.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';
import 'package:andalus_smart_pos/src/ui/screens/auth/phone_login_screen.dart';
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AppSettings _currentSettings;
  bool _hasChanges = false;
  bool _isInitialized = false;
  bool _isEditingProfile = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Load user data
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _emailController.text = user.email ?? '';
    }

    // Load settings
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
            _currentSettings = _getDefaultSettings();
            _isInitialized = true;
          });
        }
      },
      error: (error, stack) {
        if (mounted) {
          setState(() {
            _currentSettings = _getDefaultSettings();
            _isInitialized = true;
          });
        }
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

  void _toggleEditProfile() {
    setState(() {
      _isEditingProfile = !_isEditingProfile;
      if (!_isEditingProfile) {
        // Reset changes
        final authState = ref.read(authProvider);
        final user = authState.user;
        if (user != null) {
          _nameController.text = user.name;
          _phoneController.text = user.phone;
          _emailController.text = user.email ?? '';
        }
      }
    });
  }

  void _togglePasswordChange() {
    setState(() {
      _isChangingPassword = !_isChangingPassword;
      if (!_isChangingPassword) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  Future<void> _updateProfile() async {
    final authState = ref.read(authProvider);
    final user = authState.user;

    if (user == null) return;

    // TODO: Implement profile update logic
    final updatedUser = user.copyWith(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
    );

    // Update user in provider/database
    // await ref.read(authProvider.notifier).updateProfile(updatedUser);

    setState(() => _isEditingProfile = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement password change logic
    _togglePasswordChange();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('confirm')),
        content: Text(AppLocalizations.of(context)
            .translate('Are you sure you want to logout?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).translate('confirm')),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    ref.read(authProvider.notifier).logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    final localizations = AppLocalizations.of(context);
    final user = authState.user;

    if (!_isInitialized) {
      return _buildLoadingState();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          if (_hasChanges && !_isEditingProfile && !_isChangingPassword)
            TextButton(
              onPressed: _saveSettings,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          if (_isEditingProfile) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateProfile,
              tooltip: 'Save Changes',
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _toggleEditProfile,
              tooltip: 'Cancel',
            ),
          ],
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Profile Section
            _buildProfileSection(user, localizations),
            const SizedBox(height: 16),

            // Appearance & Language
            _buildAppearanceSection(themeMode, locale, localizations),
            const SizedBox(height: 16),

            // Business Settings
            _buildBusinessSettings(localizations),
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
            const SizedBox(height: 16),

            // Logout Section
            _buildLogoutSection(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF10B981)),
            const SizedBox(height: 16),
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(User? user, AppLocalizations localizations) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                'Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (!_isEditingProfile && !_isChangingPassword)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _toggleEditProfile,
                  tooltip: 'Edit Profile',
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (!_isEditingProfile) ...[
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.role.displayName ?? 'User',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phone ?? 'No Phone',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          if (_isEditingProfile) _buildProfileForm(),

          // Password Change Section
          if (_isChangingPassword) ...[
            const Divider(),
            _buildPasswordChangeForm(),
          ],

          if (!_isEditingProfile && !_isChangingPassword) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _togglePasswordChange,
                child: const Text('Change Password'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email (Optional)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildPasswordChangeForm() {
    return Column(
      children: [
        TextFormField(
          controller: _currentPasswordController,
          decoration: const InputDecoration(
            labelText: 'Current Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _newPasswordController,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Confirm New Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Update Password'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: _togglePasswordChange,
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ... Include all the existing settings building methods from your SettingsScreen
  // _buildAppearanceSection, _buildBusinessSettings, _buildPosSettings, etc.
  // Copy these methods exactly as they are in your current SettingsScreen

  Widget _buildAppearanceSection(
      ThemeMode themeMode, Locale locale, AppLocalizations localizations) {
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

  Widget _buildBusinessSettings(AppLocalizations localizations) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                localizations.businessInformation,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: localizations.shopNameEnglish,
            value: _currentSettings.shopName,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(shopName: value)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: localizations.shopNameAmharic,
            value: _currentSettings.shopNameAm,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(shopNameAm: value)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: localizations.address,
            value: _currentSettings.address,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(address: value)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: localizations.phone,
            value: _currentSettings.phone,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(phone: value)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: localizations.tinNumber,
            value: _currentSettings.tinNumber,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(tinNumber: value)),
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

  Widget _buildPosSettings() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.point_of_sale, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              const Text(
                'POS Settings',
                style: TextStyle(
                  fontSize: 18,
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

  Widget _buildCreditSettings() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              const Text(
                'Credit Settings',
                style: TextStyle(
                  fontSize: 18,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              const Text(
                'Sync Settings',
                style: TextStyle(
                  fontSize: 18,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              const Text(
                'Advanced Settings',
                style: TextStyle(
                  fontSize: 18,
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

  Widget _buildLogoutSection(AppLocalizations localizations) {
    return CustomCard(
      backgroundColor: Colors.red.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade600),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sign out from your account',
            style: TextStyle(color: Colors.red.shade600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
