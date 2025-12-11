// lib/src/ui/screens/splash_screen.dart
// Splash screen with animated logo and initial setup flow for language and theme selection.
// After setup, navigates to authentication or main app screen.
// Implements smooth animations and responsive design.

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

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  int _currentStep = 0;
  bool _showSettings = false;

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
      'description': 'English'
    },
    {
      'code': 'am',
      'name': 'Amharic',
      'nativeName': 'አማርኛ',
      'flag': '🇪🇹',
      'description': 'Amharic'
    },
  ];

  final List<Map<String, dynamic>> _themes = [
    {
      'mode': ThemeMode.light,
      'name': 'Light',
      'description': 'Bright theme',
      'icon': Icons.light_mode_outlined,
      'selectedIcon': Icons.light_mode,
    },
    {
      'mode': ThemeMode.dark,
      'name': 'Dark',
      'description': 'Dark theme',
      'icon': Icons.dark_mode_outlined,
      'selectedIcon': Icons.dark_mode,
    },
    {
      'mode': ThemeMode.system,
      'name': 'System',
      'description': 'Follow device',
      'icon': Icons.settings_outlined,
      'selectedIcon': Icons.settings,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Initial loading delay
    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      setState(() {
        _showSettings = true;
        _currentStep = 1;
      });
    }
  }

  void _selectLanguage(String languageCode) {
    ref.read(languageProvider.notifier).setLanguage(languageCode);
    _nextStep();
  }

  void _selectTheme(ThemeMode themeMode) {
    ref.read(themeProvider.notifier).setTheme(themeMode);
    _nextStep();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _proceedToApp();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _skipToApp() {
    _proceedToApp();
  }

  void _proceedToApp() {
    final authState = ref.read(authProvider);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => authState.isAuthenticated
            ? const MainNavigation()
            // : const PhoneLoginScreen(),
            : const MainNavigation(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    final isEnglish = locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress Indicator
              if (_showSettings && _currentStep > 0 && _currentStep < 3)
                _buildProgressIndicator(),

              // Main Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _showSettings
                      ? _buildSettingsFlow(isEnglish)
                      : _buildWelcomeScreen(),
                ),
              ),

              // Navigation Buttons
              if (_showSettings && _currentStep > 0 && _currentStep < 3)
                _buildNavigationButtons(isEnglish),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo with gradient
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.point_of_sale_rounded,
                size: 70,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            Text(
              'Andalus POS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              'Smart Point of Sale for Ethiopian Businesses',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Loading Indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8)),
              ),
            ),
            const SizedBox(height: 20),

            // Loading Text
            Text(
              'Initializing...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsFlow(bool isEnglish) {
    switch (_currentStep) {
      case 1:
        return _buildLanguageStep(isEnglish);
      case 2:
        return _buildThemeStep(isEnglish);
      case 3:
        return _buildReadyStep(isEnglish);
      default:
        return _buildWelcomeScreen();
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          // Step Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (index) {
              return Container(
                width: _currentStep == index + 1 ? 24 : 12,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _currentStep >= index + 1
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Step Text
          Text(
            '$_currentStep of 2',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageStep(bool isEnglish) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              Icons.language_rounded,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              isEnglish ? 'Choose Language' : 'ቋንቋ ይምረጡ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              isEnglish ? 'Select your preferred language' : 'የሚፈልጉትን ቋንቋ ይምረጡ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),

            // Language Options
            Column(
              children: _languages
                  .map((language) => _buildLanguageOption(language, isEnglish))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(Map<String, dynamic> language, bool isEnglish) {
    final isSelected =
        ref.watch(languageProvider).languageCode == language['code'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _selectLanguage(language['code']),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Flag
                Text(
                  language['flag'],
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 16),

                // Language Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language['nativeName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        language['name'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.7)
                              : Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection Indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeStep(bool isEnglish) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              Icons.palette_rounded,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              isEnglish ? 'Choose Theme' : 'ገጽታ ይምረጡ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              isEnglish
                  ? 'Select your preferred appearance'
                  : 'የሚፈልጉትን ገጽታ ይምረጡ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),

            // Theme Options
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _themes
                  .map((theme) => _buildThemeOption(theme, isEnglish))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(Map<String, dynamic> theme, bool isEnglish) {
    final isSelected = ref.watch(themeProvider) == theme['mode'];

    return Material(
      color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _selectTheme(theme['mode']),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 140,
          height: 140,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                isSelected ? theme['selectedIcon'] : theme['icon'],
                size: 36,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 12),

              // Theme Name
              Text(
                _getThemeDisplayName(theme['mode'], isEnglish),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                theme['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                      : Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadyStep(bool isEnglish) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.check_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),

        // Title
        Text(
          isEnglish ? 'You\'re All Set!' : 'ሁሉም ነገር ዝግጁ ነው!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        // Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            isEnglish
                ? 'Your preferences have been saved. Welcome to Andalus Smart POS!'
                : 'ምርጫዎችዎ ተቀምጠዋል። ወደ አንዳሉስ ማርቲን ፖስ እንኳን በደህና መጡ!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),

        // Continue Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _proceedToApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              isEnglish ? 'Get Started' : 'ጀምር',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(bool isEnglish) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          if (_currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(isEnglish ? 'Back' : 'ተመለስ'),
              ),
            ),
          if (_currentStep > 1) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                isEnglish ? 'Continue' : 'ቀጣይ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeDisplayName(ThemeMode themeMode, bool isEnglish) {
    switch (themeMode) {
      case ThemeMode.light:
        return isEnglish ? 'Light' : 'ብርሃን';
      case ThemeMode.dark:
        return isEnglish ? 'Dark' : 'ጨለማ';
      case ThemeMode.system:
        return isEnglish ? 'System' : 'ስርአት';
    }
  }
}
