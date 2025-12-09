import 'package:andalus_smart_pos/src/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';
import 'package:andalus_smart_pos/src/providers/theme_provider.dart';
import 'package:andalus_smart_pos/src/ui/screens/auth/phone_login_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/main_navigation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _showSettings = false;
  final List<Map<String, dynamic>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'am', 'name': 'Amharic', 'nativeName': 'አማርኛ'},
  ];

  final List<Map<String, dynamic>> _themes = [
    {'mode': ThemeMode.light, 'name': 'Light', 'icon': Icons.light_mode},
    {'mode': ThemeMode.dark, 'name': 'Dark', 'icon': Icons.dark_mode},
    {'mode': ThemeMode.system, 'name': 'System', 'icon': Icons.settings},
  ];

  @override
  void initState() {
    super.initState();
    // Delay showing settings to give user time to see splash
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showSettings = true;
        });
      }
    });
  }

  void _selectLanguage(String languageCode) {
    ref.read(languageProvider.notifier).setLanguage(languageCode);
  }

  void _selectTheme(ThemeMode themeMode) {
    ref.read(themeProvider.notifier).setTheme(themeMode);
  }

  void _proceedToApp() {
    // Check authentication status
    final authState = ref.read(authProvider);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => authState.isAuthenticated
            ? const MainNavigation()
            : const PhoneLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    final currentLanguage = _languages.firstWhere(
      (lang) => lang['code'] == locale.languageCode,
      orElse: () => _languages[0],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // App Logo and Title Section
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.point_of_sale,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Name
                      Text(
                        currentLanguage['code'] == 'en'
                            ? 'Andalus Smart POS'
                            : 'አንዳሉስ ማርቲን ፖስ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        currentLanguage['code'] == 'en'
                            ? 'Mobile-first POS for Ethiopian Shops'
                            : 'ለኢትዮጵያ ሱቆች የተሰራ ሞባይል ፖስ',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Settings Section (Language & Theme)
              if (_showSettings) ...[
                _buildSettingsSection(themeMode, currentLanguage),
                const SizedBox(height: 24),
              ],

              // Proceed Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentLanguage['code'] == 'en' ? 'Get Started' : 'ጀምር',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      ThemeMode themeMode, Map<String, dynamic> currentLanguage) {
    return Column(
      children: [
        // Language Selection
        _buildSettingCard(
          icon: Icons.language,
          title: currentLanguage['code'] == 'en' ? 'Language' : 'ቋንቋ',
          currentValue: currentLanguage['nativeName'],
          options: _languages.map((lang) => lang['nativeName']).toList(),
          onOptionSelected: (index) {
            _selectLanguage(_languages[index]['code']);
          },
        ),
        const SizedBox(height: 16),

        // Theme Selection
        _buildSettingCard(
          icon: Icons.palette,
          title: currentLanguage['code'] == 'en' ? 'Theme' : 'ገጽታ',
          currentValue:
              _getThemeDisplayName(themeMode, currentLanguage['code']),
          options: _themes
              .map((theme) =>
                  _getThemeDisplayName(theme['mode'], currentLanguage['code']))
              .toList(),
          onOptionSelected: (index) {
            _selectTheme(_themes[index]['mode']);
          },
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String currentValue,
    required List<String> options,
    required Function(int) onOptionSelected,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF10B981)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(options.length, (index) {
                final isSelected = currentValue == options[index];
                return ChoiceChip(
                  label: Text(options[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onOptionSelected(index);
                    }
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: const Color(0xFF10B981),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeDisplayName(ThemeMode themeMode, String languageCode) {
    switch (themeMode) {
      case ThemeMode.light:
        return languageCode == 'en' ? 'Light' : 'ብርሃን';
      case ThemeMode.dark:
        return languageCode == 'en' ? 'Dark' : 'ጨለማ';
      case ThemeMode.system:
        return languageCode == 'en' ? 'System' : 'ስርአት';
    }
  }
}
