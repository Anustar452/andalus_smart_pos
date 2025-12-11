//src/ui/screens/account/account_management_screen.dart
// Screen for managing user account settings.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';
import 'package:andalus_smart_pos/src/providers/theme_provider.dart';
import 'package:andalus_smart_pos/src/providers/language_provider.dart';
import 'package:andalus_smart_pos/src/data/models/user.dart';
import 'package:andalus_smart_pos/src/ui/screens/auth/phone_login_screen.dart';

class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  ConsumerState<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState
    extends ConsumerState<AccountManagementScreen> {
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
        _loadUserData(); // Reset changes
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
    // await ref.read(authServiceProvider).changePassword(
    //   userId,
    //   _newPasswordController.text,
    // );

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
          ] else if (!_isChangingPassword) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
              tooltip: 'Edit Profile',
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Section
          Card(
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
                        child:
                            Icon(Icons.person, color: Colors.white, size: 30),
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
                  const SizedBox(height: 16),

                  // Profile Form
                  if (_isEditing) _buildProfileForm(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Appearance & Language Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.appearanceLanguage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
            ),
          ),
          const SizedBox(height: 16),

          // Security Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security',
                    style: const TextStyle(
                      fontSize: 18,
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
          ),
          const SizedBox(height: 16),

          // Logout Section
          Card(
            color: Colors.red.shade50,
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
          ),
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
}
