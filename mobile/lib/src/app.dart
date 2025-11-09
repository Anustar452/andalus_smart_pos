import 'package:andalus_smart_pos/src/ui/screens/ReportsScreen.dart';
import 'package:andalus_smart_pos/src/ui/screens/auth/registration_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/customer_management_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/pos_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/product_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:andalus_smart_pos/src/config/app_theme.dart';
import 'package:andalus_smart_pos/src/ui/screens/main_navigation.dart';
import 'package:andalus_smart_pos/src/providers/theme_provider.dart';
import 'package:andalus_smart_pos/src/providers/language_provider.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';
import 'package:andalus_smart_pos/src/ui/screens/auth/phone_login_screen.dart';

class AndalusApp extends ConsumerWidget {
  const AndalusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Andalus Smart POS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('am', 'ET'),
      ],
      home: authState.isAuthenticated
          ? const MainNavigation()
          : const PhoneLoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/pos': (context) => const PosScreen(),
        '/products': (context) => const ProductManagementScreen(),
        '/customers': (context) => const CustomerManagementScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/register': (context) => const RegistrationScreen(), // Add this route
      },
    );
  }
}
