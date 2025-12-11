// src/ui/screens/account_setting_screen.dart
// Account settings screen for viewing and updating user profile, preferences, and security settings.
import 'package:andalus_smart_pos/src/config/app_theme.dart';
import 'package:andalus_smart_pos/src/config/font_theme.dart';
import 'package:andalus_smart_pos/src/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';
import 'package:andalus_smart_pos/src/providers/theme_provider.dart';
import 'package:andalus_smart_pos/src/providers/language_provider.dart';
// import 'package:andalus_smart_pos/src/config/theme/font_theme.dart';

import 'package:andalus_smart_pos/src/utils/calendar_utils.dart';
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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = ref.read(authProvider);
    final user = authState.user;

    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _loadUserData();
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

    setState(() => _isEditing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('settingsSaved')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // TODO: Implement password change logic
    _togglePasswordChange();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
    final fontTheme = ref.watch(fontThemeProvider);
    final localizations = AppLocalizations.of(context);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('Account Settings')),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateProfile,
              tooltip: 'Save Changes',
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _toggleEdit,
              tooltip: 'Cancel',
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Section
          _buildProfileSection(user, localizations),
          const SizedBox(height: 16),

          // Calendar Settings
          _buildCalendarSection(localizations),
          const SizedBox(height: 16),

          // Language Settings
          _buildLanguageSection(locale, localizations),
          const SizedBox(height: 16),

          // Font Settings
          _buildFontSettingsSection(fontTheme, localizations),
          const SizedBox(height: 16),

          // Theme Settings
          _buildThemeSection(themeMode, localizations),
          const SizedBox(height: 16),

          // Security Section
          _buildSecuritySection(localizations),
          const SizedBox(height: 16),

          // Logout Section
          _buildLogoutSection(localizations),
        ],
      ),
    );
  }

  Widget _buildProfileSection(User? user, AppLocalizations localizations) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                if (!_isEditing && !_isChangingPassword)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _toggleEdit,
                    tooltip: 'Edit Profile',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditing) _buildProfileForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(AppLocalizations localizations) {
    final currentCalendar = CalendarUtils.currentCalendar;

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF10B981)),
                const SizedBox(width: 12),
                Text(
                  'Calendar System',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Choose your preferred calendar system for date displays throughout the app.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildCalendarOption(
                  'Gregorian',
                  CalendarType.gregorian,
                  currentCalendar,
                  Icons.calendar_today,
                ),
                _buildCalendarOption(
                  'Ethiopian',
                  CalendarType.ethiopian,
                  currentCalendar,
                  Icons.language,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Current date: ${AppDateUtils.formatFullDate(DateTime.now())}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarOption(
    String label,
    CalendarType type,
    CalendarType currentType,
    IconData icon,
  ) {
    final isSelected = currentType == type;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        CalendarUtils.setCalendarType(type);
        setState(() {});
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: const Color(0xFF10B981).withOpacity(0.2),
      checkmarkColor: const Color(0xFF10B981),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildLanguageSection(Locale locale, AppLocalizations localizations) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.language, color: Color(0xFF10B981)),
                const SizedBox(width: 12),
                Text(
                  localizations.translate('language'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Locale>(
              value: locale,
              decoration: InputDecoration(
                labelText: 'App Language',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
              onChanged: (newLocale) {
                if (newLocale != null) {
                  ref
                      .read(languageProvider.notifier)
                      .setLanguage(newLocale.languageCode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSettingsSection(
      FontTheme fontTheme, AppLocalizations localizations) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.font_download, color: Color(0xFF10B981)),
                const SizedBox(width: 12),
                Text(
                  'Font Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // English Font
            _buildFontSelector(
              'English Font',
              fontTheme.englishFont,
              AppFontFamily.values,
              (font) =>
                  ref.read(fontThemeProvider.notifier).updateEnglishFont(font),
            ),
            const SizedBox(height: 16),

            // Amharic Font
            _buildFontSelector(
              'Amharic Font',
              fontTheme.amharicFont,
              [AppFontFamily.notoSansEthiopic, AppFontFamily.AbyssinicaSIL],
              (font) =>
                  ref.read(fontThemeProvider.notifier).updateAmharicFont(font),
            ),
            const SizedBox(height: 16),

            // Font Size Scaling
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Font Size Scale',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${(fontTheme.fontSizeScale * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: fontTheme.fontSizeScale,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  onChanged: (value) {
                    ref.read(fontThemeProvider.notifier).updateFontScale(value);
                  },
                  activeColor: const Color(0xFF10B981),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Smaller', style: TextStyle(fontSize: 12)),
                    Text('Larger', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSelector(
    String label,
    AppFontFamily currentFont,
    List<AppFontFamily> options,
    Function(AppFontFamily) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((font) {
            final isSelected = currentFont == font;
            return FilterChip(
              label: Text(font.name),
              selected: isSelected,
              onSelected: (selected) => onChanged(font),
              backgroundColor: Colors.grey.shade100,
              selectedColor: const Color(0xFF10B981).withOpacity(0.2),
              checkmarkColor: const Color(0xFF10B981),
              labelStyle: TextStyle(
                color:
                    isSelected ? const Color(0xFF10B981) : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemeSection(
      ThemeMode themeMode, AppLocalizations localizations) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Color(0xFF10B981)),
                const SizedBox(width: 12),
                Text(
                  localizations.translate('themeMode'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ThemeMode>(
              value: themeMode,
              decoration: InputDecoration(
                labelText: 'Theme Mode',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(localizations.translate('light')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(localizations.translate('dark')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(localizations.translate('systemDefault')),
                ),
              ],
              onChanged: (newMode) {
                if (newMode != null) {
                  ref.read(themeProvider.notifier).setTheme(newMode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(AppLocalizations localizations) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_isChangingPassword) ...[
              _buildPasswordChangeForm(),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isChangingPassword
                    ? _changePassword
                    : _togglePasswordChange,
                child: Text(_isChangingPassword
                    ? 'Change Password'
                    : 'Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(AppLocalizations localizations) {
    return CustomCard(
      backgroundColor: Colors.red.shade50,
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.red.shade600),
        title: Text(
          'Logout',
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(Icons.arrow_forward, color: Colors.red.shade600),
        onTap: _logout,
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
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
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
      ],
    );
  }
}
