import 'package:andalus_smart_pos/src/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';
import 'package:andalus_smart_pos/src/ui/screens/auth/phone_login_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/main_navigation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize app dependencies and check auth status
    await Future.delayed(const Duration(seconds: 2));

    // Check authentication status
    final authState = ref.read(authProvider);

    if (mounted) {
      _navigateToNextScreen(authState.isAuthenticated);
    }
  }

  void _navigateToNextScreen(bool isAuthenticated) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            isAuthenticated ? const MainNavigation() : const PhoneLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    final isEnglish = locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
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
              child: const Icon(
                Icons.point_of_sale,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              isEnglish ? 'Andalus Smart POS' : 'አንዳሉስ ማርቲን ፖስ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              isEnglish
                  ? 'Mobile-first POS for Ethiopian Shops'
                  : 'ለኢትዮጵያ ሱቆች የተሰራ ሞባይል ፖስ',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),

            // Loading Text
            Text(
              isEnglish ? 'Loading...' : 'በማቀናበር ላይ...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
