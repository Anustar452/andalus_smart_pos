import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF10B981),
      brightness: Brightness.light,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF10B981),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF10B981),
        side: const BorderSide(color: Color(0xFF10B981)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF10B981),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF10B981),
      unselectedItemColor: Colors.grey.shade600,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF10B981),
      brightness: Brightness.dark,
    ),
    fontFamily: 'Inter',
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.grey.shade800,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    // Add other dark theme properties as needed
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey.shade900,
      selectedItemColor: const Color(0xFF10B981),
      unselectedItemColor: Colors.grey.shade500,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    cardColor: Colors.grey.shade800,
    dialogBackgroundColor: Colors.grey.shade800,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.grey.shade900,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF10B981),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    // Add other dark theme properties as needed
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.grey.shade200),
      bodyMedium: TextStyle(color: Colors.grey.shade200),
      bodySmall: TextStyle(color: Colors.grey.shade200),
    ),
  );
}
